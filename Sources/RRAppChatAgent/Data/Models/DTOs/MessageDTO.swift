//
//  MessageDTO.swift
//  RRAppChatAgent
//
//  Created by Raj S on 30/12/24.
//

import Foundation

// MARK: - MessageDTO
struct MessageDTO {
    let id: String
    let threadId: String
    let role: ParticipantRole
    let content: MessageContent
}

// MARK: - MessageDTO + MessageContent
extension MessageDTO {
    enum MessageContent {
        case text(String)
        case unknown
    }
}

// MARK: - MessageDTO + ParticipantRole
extension MessageDTO {
    enum ParticipantRole: String, Codable {
        case agent
        case user
        case unknown
        
        init(rawValue: String) {
            switch rawValue {
            case "agent": self = .agent
            case "user": self = .user
            default: self = .unknown
            }
        }
    }
}

// MARK: - MessageDTO + MessageListResponse
extension MessageListResponse.Message {
    func mapToMessageDTO() -> MessageDTO {
        let messageContent: MessageDTO.MessageContent
        
        if let content = content.first {
            switch content.type {
            case "text":
                messageContent = .text(content.text?.value ?? "")
            default:
                messageContent = .unknown
            }
        } else {
            messageContent = .unknown
        }
    
        return MessageDTO(
            id: id,
            threadId: threadId,
            role: MessageDTO.ParticipantRole(rawValue: role),
            content: messageContent
        )
    }
}
