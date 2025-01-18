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
    
    @ObservedObject
    var viewModel: ThreadsViewModel
    
    @Inject
    var theme: ChatAppTheme
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.threads) { thread in
                    ThreadCellView(
                        viewModel: thread,
                        isSelected: viewModel.selectedThreadId == thread.id
                    )
                    .padding(.horizontal, 16)
                    .onTapGesture {
                        viewModel.didSelectedThread(id: thread.id)
                    }
                }
                
            }
        }
        .background(theme.chatColor.thread.unSelected.background)
        .navigationTitle("Threads")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        viewModel.createNewThread()
                    }, label: {
                        Image(systemName: "plus")
                    }
                )
                .foregroundStyle(theme.color.primary)
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
    
    var assistantId: String? {
        didSet {
            self.assignThreads(for: threadsRepository.currentThreads.value)
        }
    }
    
    init(assistantId: String?) {
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
                    self.assignThreads(for: threads)
                }
            )
            .store(in: &cancellables)
    }
    
    private func assignThreads(for threads: [String: [ThreadsDTO]]) {
        guard let assistantId else { return }
        
        let sortedThreads = threads[assistantId]?.sorted(by: { $0.lastUpdatedAt > $1.lastUpdatedAt }) ?? []
        self.threads = sortedThreads.map { .init(model: $0) }
        
        if self.selectedThreadId == nil, let id = self.threads.first?.id {
            self.didSelectedThread(id: id)
        }
    }
    
    func createNewThread() {
        guard let assistantId else { return }
        
        Task {
            let id = try? await threadsRepository.createAThread(for: assistantId)
        }
    }
    
    func didSelectedThread(id: String) {
        selectedThreadId = id
    }
    
}


struct ThreadCellView: View {
    
    let viewModel: ThreadCellViewModel
    
    let isSelected: Bool
    
    @Inject
    var theme: ChatAppTheme
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text(viewModel.primaryText)
                    .lineLimit(1)
                    .foregroundStyle(primaryColor)
                    .font(theme.chatFont.thread.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(viewModel.info)
                    .foregroundStyle(infoColor)
                    .font(theme.chatFont.thread.info)
            }
            
            Text(viewModel.secondaryText)
                .foregroundStyle(secondaryColor)
                .font(theme.chatFont.thread.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
               
        }
        .padding()
        .background(
            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                .fill(backgroundColor)
        )
    }
    
    var primaryColor: Color {
        let thread = theme.chatColor.thread
        return isSelected ? thread.selected.primaryText : thread.unSelected.primaryText
    }
    
    var secondaryColor: Color {
        let thread = theme.chatColor.thread
        return isSelected ? thread.selected.secondaryText : thread.unSelected.secondaryText
    }
    
    var infoColor: Color {
        let thread = theme.chatColor.thread
        return isSelected ? thread.selected.infoText : thread.unSelected.infoText
    }
    
    var backgroundColor: Color {
        let thread = theme.chatColor.thread
        return isSelected ? thread.selected.background : thread.unSelected.background
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
