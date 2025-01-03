//
//  MessageListResponse.swift
//  RRAppChatAgent
//
//  Created by Raj S on 30/12/24.
//

import Foundation

// MARK: - MessageListResponse
struct MessageListResponse: Decodable {
    let data: [Message]
    
    struct Message: Decodable {
        let id: String
        let threadId: String
        let role: String
        let createdAt: TimeInterval
        let content: [MessageContent]
        
        enum CodingKeys: String, CodingKey {
            case id
            case threadId = "thread_id"
            case createdAt = "created_at"
            case role
            case content
        }
    }
    
    struct MessageContent: Decodable {
        let type: String
        let text: MessageContentText?
    }
    
    struct MessageContentText: Decodable {
        let value: String
    }
}
