//
//  HomeViewModel.swift
//  RRAppChatAgent
//
//  Created by Raj S on 19/01/25.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published
    var assistantsViewModel: AssistantsListViewModel = .init(assistantRepository: AssistantRepositoryImpl())
    
    @Published
    var threadsViewModel = ThreadsViewModel(assistantId: nil)
    
    @Published
    var chatViewModel: ChatViewModel = ChatViewModel(input: .init(containerData: nil))
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init() {
        listenToAssistantObservers()
        listenToThreadObservers()
    }
    
    func listenToAssistantObservers() {
        assistantsViewModel.$selectedAssistantId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedAssistantId in
                guard let self, let selectedAssistantId else { return }
                
                if self.threadsViewModel.assistantId != selectedAssistantId {
                    self.chatViewModel.containerData = nil
                    self.threadsViewModel.assistantId = selectedAssistantId
                }
                
            }
            .store(in: &cancellables)
    }
    
    func listenToThreadObservers() {
        threadsViewModel.$selectedThreadId
            .sink { [weak self] selectedThreadId  in
                guard let self,
                      let selectedThreadId,
                      let selectedAssistantId = self.assistantsViewModel.selectedAssistantId else {
                    self?.chatViewModel.containerData = nil
                    return
                }
                
                self.chatViewModel.containerData = .init(
                    threadId: selectedThreadId,
                    assistantId: selectedAssistantId
                )
            }
            .store(in: &cancellables)
    }
}
