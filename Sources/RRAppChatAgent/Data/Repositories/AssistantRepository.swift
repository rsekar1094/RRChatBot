//
//  AssistantRepository.swift
//  RRAppChatAgent
//
//  Created by Raj S on 06/01/25.
//

import Foundation
import RRAppUtils
import RRAppNetwork

// MARK: - AssistantRepository
protocol AssistantRepository: Sendable {
   func fetchAllAssistants() async throws -> [AssistantDTO]
}

// MARK: - AssistantRepositoryImpl
actor AssistantRepositoryImpl: AssistantRepository {
    
    @Inject
    private var networkManager: NetworkService
    
    private var commonAdditionalHeader: [String: String] = [
        "OpenAI-Beta" : "assistants=v2"
    ]
    
    func fetchAllAssistants() async throws -> [AssistantDTO] {
        let response: AssistantListResponse = try await networkManager.perform(
            request: .init(
                method: .get,
                path: NetworkPath.Assistant.listAll.path,
                body: nil,
                additionalHeader: commonAdditionalHeader
            )
        )
        
        return response.data.sorted { $0.created_at < $1.created_at }.map { $0.mapToAssistantDTO() }
    }
}

extension AssistantListResponse.Assistant {
    func mapToAssistantDTO() -> AssistantDTO {
        AssistantDTO(
            id: id,
            name: name,
            imageUrl: URL(string: metadata["imageUrl"] ?? ""),
            createdAt: created_at
        )
    }
}
