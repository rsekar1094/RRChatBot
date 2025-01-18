//
//  ChatRepository.swift
//  RRAppChatAgent
//
//  Created by Raj S on 30/12/24.
//

import Foundation
import RRAppNetwork
import RRAppUtils

// MARK: - ChatRepository
protocol ChatRepository: Sendable {
    func createAThread() async throws -> String
    
    func appendUserMessage(into threadId: String, assistantId: String, message: String) async throws -> String
    func fetchAllMessage(from threadId: String) async throws -> [MessageDTO]
    
    func runAndListen(to threadId: String, assistantId: String, listener: @escaping @Sendable (ChatEventData) -> Void) async throws
    func createAndRunThenListen(assistantId: String, userMessage: String, listener: @escaping @Sendable (ChatEventData) -> Void) async throws
}

// MARK: - ChatRepositoryImpl
actor ChatRepositoryImpl: ChatRepository {
    
    @Inject
    private var networkManager: NetworkService
    
    @Inject
    private var threadRepository: ThreadsRepository
    
    private var streamingNetworkManager: StreamingNetworkService
    private var streamingListeners: [Int: @Sendable (ChatEventData) -> Void] = [:]
    
    init(streamingNetworkManager: StreamingNetworkService) {
        self.streamingNetworkManager = streamingNetworkManager
        Task {
            await self.streamingNetworkManager.setDelegate(self)
        }
    }

    private var commonAdditionalHeader: [String: String] = [
        "OpenAI-Beta" : "assistants=v2"
    ]
}

// MARK: - ChatRepositoryImpl + Threads
extension ChatRepositoryImpl {
    func createAThread() async throws -> String {
        let response: ThreadCreationResponse = try await networkManager.perform(
            request: .init(
                method: .post,
                path: NetworkPath.Thread.create.path,
                body: nil,
                additionalHeader: commonAdditionalHeader
            )
        )
        return response.id
    }
}

// MARK: - ChatRepositoryImpl + Message
extension ChatRepositoryImpl {
    func appendUserMessage(into threadId: String, assistantId: String, message: String) async throws -> String {
        let requestBody: [String: Any] = [
            "role": "user",
            "content": message
        ]
        
        threadRepository.updateThread(threadId: threadId, lastSneakPeakMessage: message, in: assistantId)
        
        let response: MessageCreationResponse = try await networkManager.perform(
            request: .init(
                method: .post,
                path: NetworkPath.Message.create(threadId: threadId).path,
                body: requestBody,
                additionalHeader: commonAdditionalHeader
            )
        )
    
        return response.id
    }
    
    func fetchAllMessage(from threadId: String) async throws -> [MessageDTO] {
        let response: MessageListResponse = try await networkManager.perform(
            request: .init(
                method: .get,
                path: NetworkPath.Message.listAll(threadId: threadId).path,
                body: nil,
                additionalHeader: commonAdditionalHeader
            )
        )
        
        return response.data.sorted { $0.createdAt < $1.createdAt }.map { $0.mapToMessageDTO() }
    }
}

// MARK: - ChatRepositoryImpl + Runs
extension ChatRepositoryImpl {
    func runAndListen(
        to threadId: String,
        assistantId: String,
        listener: @escaping @Sendable (ChatEventData) -> Void
    ) async throws {
        let body: [String: Any] = [
            "assistant_id": assistantId,
            "stream": true
        ]
        
        let id = try await streamingNetworkManager.listen(
            to: .init(
                method: .post,
                path: NetworkPath.Run.create(threadId: threadId).path,
                body: body,
                additionalHeader: commonAdditionalHeader
            )
        )
        self.streamingListeners[id] = listener
    }
    
    func createAndRunThenListen(
        assistantId: String,
        userMessage: String,
        listener: @escaping @Sendable (ChatEventData) -> Void
    ) async throws {
        let body: [String: Any] = [
            "assistant_id": assistantId,
            "thread" : [
                "messages": [
                    ["role": "user", "content": userMessage]
                ]
            ],
            "stream": true
        ]
        
        let id = try await streamingNetworkManager.listen(
            to: .init(
                method: .post,
                path: NetworkPath.Run.createThreadAndRun.path,
                body: body,
                additionalHeader: commonAdditionalHeader
            )
        )
        self.streamingListeners[id] = listener
    }
}
extension ChatRepositoryImpl: StreamingNetworkDelegate  {
    nonisolated func didReceive(data: Data, taskId: Int) {
        guard let textChunk = String(data: data, encoding: .utf8) else { return }
        
        Task {
            let lines = textChunk.split(separator: "\n")
            
            let event: ChatEvent
            if let line = lines.first?.trimmingCharacters(in: .whitespaces) {
                let eventValue = line.replacingOccurrences(of: "event:", with: "").trimmingCharacters(in: .whitespaces)
                event = .init(rawValue: eventValue) ?? .unknown
            } else {
                event = .unknown
            }
            
            var meta: ChatEventMeta?
            let jsonString = lines.last?.replacingOccurrences(of: "data:", with: "").trimmingCharacters(in: .whitespaces) ?? ""
            print("jsonString \(jsonString) ===================== \n\n")
            
            if let jsonData = jsonString.data(using: .utf8),
               let metaValue = try? JSONDecoder().decode(ChatEventMeta.self, from: jsonData) {
                meta = metaValue
            }
            
            await self.streamingListeners[taskId]?(.init(event: event, meta: meta))
        }
    }
}

public struct ChatEventData: Sendable {
    public let event: ChatEvent
    public let meta: ChatEventMeta?
}


public enum ChatEvent: String, Sendable {
    case thread = "thread"
    case threadRunCreated = "thread.run.created"
    case threadQueued = "thread.run.queued"
    case threadInProgress = "thread.run.in_progress"
    case threadStepCreated = "thread.run.step.created"
    case threadStepInProgress = "thread.run.step.in_progress"
    case threadMessageCreated = "thread.message.created"
    case threadMessageInProgress = "thread.message.in_progress"
    case threadMessageDelta = "thread.message.delta"
    case threadMessageCompleted = "thread.message.completed"
    case threadStepCompleted = "thread.run.step.completed"
    case threadRunCompleted = "thread.run.completed"
    case unknown
}

public struct ChatEventMeta: Decodable, Sendable {
    let threadId: String?
    let id: String?
    let delta: ChatEventDelta?
    let content: [ChatEventContent]?
    
    enum CodingKeys: String, CodingKey {
        case threadId = "thread_id"
        case id
        case delta
        case content
    }
}

public struct ChatEventDelta: Decodable, Sendable {
    let content: [ChatEventContent]
    
    enum CodingKeys: String, CodingKey {
        case content = "content"
    }
}

public struct ChatEventContent: Decodable, Sendable {
    let text: ChatEventContentText?
    
    enum CodingKeys: String, CodingKey {
        case text = "text"
    }
}

public struct ChatEventContentText: Decodable, Sendable {
    let value: String
}
