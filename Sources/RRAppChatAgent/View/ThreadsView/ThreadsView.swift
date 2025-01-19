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
    
    @EnvironmentObject
    var themeManager: ThemeManager
    
    var theme: ChatAppTheme { return themeManager.current }
    
    var body: some View {
        VStack {
            if viewModel.threads.isEmpty {
                EmptyStateView(
                    viewModel: .init(
                        imageName: "figure.snowboarding",
                        title: "No Threads",
                        message: "Create your first thread by clicking the plus button in the top right corner.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
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
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
