//
//  ChatEventData.swift
//  RRAppChatAgent
//
//  Created by Raj S on 19/01/25.
//

import Foundation

// MARK: - ChatEventData
public struct ChatEventData: Sendable {
    public let event: ChatEvent
    public let meta: ChatEventMeta?
}

// MARK: - ChatEvent
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

// MARK: - ChatEventMeta
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

// MARK: - ChatEventDelta
public struct ChatEventDelta: Decodable, Sendable {
    let content: [ChatEventContent]
    
    enum CodingKeys: String, CodingKey {
        case content = "content"
    }
}

// MARK: - ChatEventContent
public struct ChatEventContent: Decodable, Sendable {
    let text: ChatEventContentText?
    
    enum CodingKeys: String, CodingKey {
        case text = "text"
    }
}

// MARK: - ChatEventContentText
public struct ChatEventContentText: Decodable, Sendable {
    let value: String
}
