//
//  AppThemeColor.swift
//  RRAppChatAgent
//
//  Created by Raj S on 25/12/24.
//

import Foundation
import SwiftUI
import RRAppTheme

struct ChatAppThemeColor: Decodable, ThemeColor {
    let primary: Color
    let secondary: Color
    let error: Color
    
    let chat: Chat
    let thread: Thread
    let agent: Agent
   
    struct Chat: Decodable {
        let user: MessageBubble
        let agent: MessageBubble
        let background: Color
        let textInput: TextInput
        
        struct MessageBubble: Decodable {
            let background: Color
            let text: Color
        }
        
        struct TextInput: Decodable {
            let background: Color
            let placeholder: Color
            let text: Color
        }
    }
    
    struct Thread: Decodable {
        let selected: ContentThread
        let unSelected: ContentThread
    
        struct ContentThread: Decodable {
            let background: Color
            let primaryText: Color
            let secondaryText: Color
            let infoText: Color
        }
    }
    
    struct Agent: Decodable {
        let unselected: Content
        let selected: Content
        
        struct Content: Decodable {
            let background: Color
            let text: Color
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case primary
        case secondary
        case error
        case chat
        case thread
        case agent
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        primary = try container.decode(Color.self, forKey: .primary)
        secondary = try container.decode(Color.self, forKey: .secondary)
        error = try container.decode(Color.self, forKey: .error)
        chat = try container.decode(Chat.self, forKey: .chat)
        thread = try container.decode(Thread.self, forKey: .thread)
        agent = try container.decode(Agent.self, forKey: .agent)
    }
}

extension Color: @retroactive Decodable {
    enum CodingKeys: CodingKey {
        case light
        case dark
    }
    
    public init(from decoder: any Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
            let hexValue = try? container.decode(String.self) {
            self = Color(uiColor: UIColor(hex: hexValue))
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let light = try container.decode(String.self, forKey: .light)
            let dark = try container.decode(String.self, forKey: .dark)
            self = Color(
                uiColor: UIColor(
                    dynamicProvider: { trait in
                        if trait.userInterfaceStyle == .light {
                            return UIColor(hex: light)
                        } else {
                            return UIColor(hex: dark)
                        }
                    }
                )
            )
        }
    }
}
