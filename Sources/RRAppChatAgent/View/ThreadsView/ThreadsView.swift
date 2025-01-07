//
//  ThreadsView.swift
//  RRAppChatAgent
//
//  Created by Raj S on 05/01/25.
//

import Foundation
import SwiftUI
import Combine
import RRAppUtils

struct ThreadsView: View {
    
    @ObservedObject var viewModel: ThreadsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Button("Add Thread") {
                    viewModel.createNewThread()
                }
                
                ForEach(viewModel.threads) { thread in
                    ThreadCellView(viewModel: thread, isSelected: viewModel.selectedThreadId == thread.id)
                        .onTapGesture {
                            viewModel.didSelectedThread(id: thread.id)
                        }
                }
                
            }
        }
    }
}

@MainActor
class ThreadsViewModel: ObservableObject {
    @Published
    var threads: [ThreadCellViewModel] = []
    
    @Published
    var selectedThreadId: String?
    
    @Inject
    var threadsRepository: ThreadsRepository
    
    private var cancellables: Set<AnyCancellable> = []
    
    let assistantId: String
    
    init(assistantId: String) {
        self.assistantId = assistantId
        assignListener()
    }
    
    func assignListener() {
        threadsRepository.currentThreads
            .sink(
                receiveCompletion: { _ in
                    
                },
                receiveValue: { [weak self] threads in
                    guard let self else { return }
                    let sortedThreads = threads[assistantId]?.sorted(by: { $0.lastUpdatedAt > $1.lastUpdatedAt }) ?? []
                    self.threads = sortedThreads.map { .init(model: $0) }
                    
                    if self.selectedThreadId == nil, let id = self.threads.first?.id {
                        self.didSelectedThread(id: id)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func createNewThread() {
        threadsRepository.createAThread(for: assistantId)
    }
    
    func didSelectedThread(id: String) {
        selectedThreadId = id
    }
    
}


struct ThreadCellView: View {
    
    let viewModel: ThreadCellViewModel
    
    let isSelected: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.primaryText)
                
                Spacer()
                
                Text(viewModel.info)
            }
            
            Text(viewModel.secondaryText)
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                    .stroke(Color.red, lineWidth: 2)
            }
        }
    }
}

struct ThreadCellViewModel: Identifiable {
    let id: String
    let primaryText: String
    let secondaryText: String
    let info: String
    
}


extension ThreadCellViewModel {
    init(model: ThreadsDTO) {
        self.id = model.threadId
        self.info = Date(timeIntervalSince1970: model.lastUpdatedAt).info
        self.primaryText = model.threadName
        self.secondaryText = model.lastMessageSneakPeak
    }
}

private extension Date {
    var info: String {
        let dayDifference = Calendar.current.dateComponents([.day], from: self, to: Date())
        if dayDifference.day == 0 {
            let hourDifference = Calendar.current.dateComponents([.hour], from: self, to: Date())
            if hourDifference.hour == 0 {
                let minuteDifference = Calendar.current.dateComponents([.minute], from: self, to: Date())
                return "\(minuteDifference.minute)m"
            } else {
                return "\(hourDifference)h"
            }
        } else {
            return "\(dayDifference)d"
        }
    }
}
