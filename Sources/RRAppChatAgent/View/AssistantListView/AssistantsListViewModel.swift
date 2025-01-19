//
//  AssistantsListViewModel.swift
//  RRAppChatAgent
//
//  Created by Raj S on 19/01/25.
//

import Foundation

// MARK: - AssistantsListViewModel
@MainActor
class AssistantsListViewModel: ObservableObject {
    
    @Published
    var assistants: [AssistantListCellViewModel] = []
    
    @Published
    var selectedAssistantId: String?
    
    let assistantRepository: AssistantRepository
    
    init(assistantRepository: AssistantRepository) {
        self.assistantRepository = assistantRepository
        Task {
            await fetchAllAssistants()
        }
    }
    
    func fetchAllAssistants() async {
        do {
            let assistants = try await assistantRepository.fetchAllAssistants()
            self.assistants = assistants.map { .init(name: $0.name, imageUrl: $0.imageUrl, id: $0.id) }
            if let id = assistants.first?.id {
                self.didSelectedAssistant(with: id)
            }
        } catch {
            self.assistants = []
        }
    }
    
    func didSelectedAssistant(with id: String) {
        selectedAssistantId = id
    }
}
