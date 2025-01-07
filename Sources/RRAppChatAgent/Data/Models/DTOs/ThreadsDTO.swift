//
//  ThreadsDTO.swift
//  RRAppChatAgent
//
//  Created by Raj S on 05/01/25.
//

import Foundation

// MARK: - ThreadsDTO
struct ThreadsDTO: Codable, Sendable {
    let threadId: String
    let createdAt: TimeInterval
    let threadName: String
    let lastUpdatedAt: TimeInterval
    let lastMessageSneakPeak: String
}
