//
//  ThreadsRepository.swift
//  RRAppChatAgent
//
//  Created by Raj S on 05/01/25.
//

import Foundation
import RRAppUtils
import Combine
import RRAppNetwork

// MARK: - ThreadsRepository
protocol ThreadsRepository: Sendable {
    var currentThreads: CurrentValueSubject<[String: [ThreadsDTO]], Never> { get }
    func appendNewThread(thread: ThreadsDTO, in assistantId: String)
    func updateThread(threadId: String, lastSneakPeakMessage: String, in assistantId: String)
    func createAThread(for assistantId: String) async throws -> String
}

// MARK: - ThreadsRepositoryImpl
struct ThreadsRepositoryImpl: @unchecked Sendable, ThreadsRepository {
    
    private let threadsKey: String = "chat.threads"
    
    let currentThreads: CurrentValueSubject<[String: [ThreadsDTO]], Never> = .init([:])
    
    private var commonAdditionalHeader: [String: String] = [
        "OpenAI-Beta" : "assistants=v2"
    ]
    
    @Inject
    private var networkManager: NetworkService
    
    init() {
        assignCurrentThreads()
    }
    
    func assignCurrentThreads() {
        guard let threadsData = UserDefaults.standard.data(forKey: threadsKey),
              let json = try? JSONManager.dictionaryFromData(threadsData),
              let threads = try? JSONDecoder().decode([String: [ThreadsDTO]].self, from: threadsData) else {
            return
        }
        
        currentThreads.send(threads)
    }
    
    func appendNewThread(thread: ThreadsDTO, in assistantId: String) {
        var existingData = currentThreads.value
        var existingThreads = existingData[assistantId] ?? []
        existingThreads.append(thread)
        existingData[assistantId] = existingThreads
        if let data = try? JSONEncoder().encode(existingData) {
            UserDefaults.standard.set(data, forKey: threadsKey)
        }
        currentThreads.send(existingData)
    }
    
    func updateThread(threadId: String, lastSneakPeakMessage: String, in assistantId: String) {
        var existingData = currentThreads.value
        var existingThreads = existingData[assistantId] ?? []
        
        if let index = existingThreads.firstIndex(where: { $0.threadId == threadId }) {
            let oldData = existingThreads[index]
            existingThreads.remove(at: index)
            existingThreads.insert(
                .init(
                    threadId: oldData.threadId,
                    createdAt: oldData.createdAt,
                    threadName: oldData.threadName,
                    lastUpdatedAt: Date().timeIntervalSince1970,
                    lastMessageSneakPeak: lastSneakPeakMessage
                ),
                at: index
            )
        }
        
        existingData[assistantId] = existingThreads
        
        Task { @MainActor in
            if let data = try? JSONEncoder().encode(existingData) {
                UserDefaults.standard.set(data, forKey: threadsKey)
            }
            
            currentThreads.send(existingData)
        }
    }
}

extension ThreadsRepositoryImpl {
    
    @preconcurrency
    func createAThread(for assistantId: String) async throws -> String {
        try await _createAThread(for: assistantId)
    }
    
    func _createAThread(for assistantId: String) async throws -> String {
        let response: ThreadCreationResponse = try await networkManager.perform(
            request: .init(
                method: .post,
                path: NetworkPath.Thread.create.path,
                body: nil,
                additionalHeader: commonAdditionalHeader
            )
        )
        Task { @MainActor in
            self.appendNewThread(
                thread: .init(
                    threadId: response.id,
                    createdAt: Date().timeIntervalSince1970,
                    threadName: "Thread #\((currentThreads.value[assistantId]?.count ?? 0) + 1)",
                    lastUpdatedAt: Date().timeIntervalSince1970,
                    lastMessageSneakPeak: ""
                ),
                in: assistantId
            )
        }
        return response.id
    }
}
