//
//  Theme.swift
//  RRAppChatAgent
//
//  Created by Raj S on 25/12/24.
//

import Foundation
import RRAppTheme
import SwiftUI

enum ChatTheme: String, CaseIterable, Decodable {
    case whatsapp
    case instagram
    case swiggy
    case netflix
    case linkedIn
}

struct ChatAppTheme: Decodable, Theme {
    var font: ThemeFont { return chatFont }
    var color: ThemeColor { return chatColor }
    
    let chatFont: ChatAppThemeFont
    let chatColor: ChatAppThemeColor
    let type: ChatTheme
    
    enum CodingKeys: String, CodingKey {
        case type
        case font
        case color
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(ChatTheme.self, forKey: .type)
        self.chatFont = try container.decode(ChatAppThemeFont.self, forKey: .font)
        self.chatColor = try container.decode(ChatAppThemeColor.self, forKey: .color)
    }
}
