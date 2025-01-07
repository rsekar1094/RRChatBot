//
//  Threads.swift
//  RRAppChatAgent
//
//  Created by Raj S on 05/01/25.
//

import Foundation

// MARK: - ThreadData
struct ThreadData: Codable {
    let threadId: String
    let createdAt: TimeInterval
    let threadName: String
}
