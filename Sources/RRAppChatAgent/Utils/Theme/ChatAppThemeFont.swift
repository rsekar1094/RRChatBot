//
//  AppThemeFont.swift
//  RRAppChatAgent
//
//  Created by Raj S on 25/12/24.
//

import Foundation
import SwiftUI
import RRAppTheme

struct ChatAppThemeFont: Decodable, ThemeFont {
    let headline: Font
    let body: Font
    let chat: Chat
    let thread: Thread
    let agent: Agent
    
    struct Chat: Decodable {
        let message: Font
        let info: Font
        let messageInput: MessageInput
        
        struct MessageInput: Decodable {
            let placeholder: Font
            let text: Font
        }
    }
    
    struct Thread: Decodable {
        let primary: Font
        let secondary: Font
        let info: Font
    }
    
    struct Agent: Decodable {
        let primary: Font
    }
    
    enum CodingKeys: String, CodingKey {
        case headline
        case body
        case chat
        case thread
        case agent
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        body = try container.decode(Font.self, forKey: .body)
        headline = try container.decode(Font.self, forKey: .headline)
        chat = try container.decode(Chat.self, forKey: .chat)
        thread = try container.decode(Thread.self, forKey: .thread)
        agent = try container.decode(Agent.self, forKey: .agent)
    }
}

extension Font: @retroactive Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(FontDecodable.self)
        
        switch value.type {
        case "regular": self = .system(size: value.size)
        case "bold": self = .system(size: value.size, weight: .bold)
        case "medium": self = .system(size: value.size, weight: .medium)
        case "semibold": self = .system(size: value.size, weight: .semibold)
        case "thin": self = .system(size: value.size, weight: .thin)
        default:
            self = .system(size: value.size)
        }
    }
}

struct FontDecodable: Decodable {
    let type: String
    let size: CGFloat
}
