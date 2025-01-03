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

struct AppTheme: Decodable, Theme {
    let font: ThemeFont
    let color: ThemeColor
    let type: ChatTheme
    
    enum CodingKeys: String, CodingKey {
        case type
        case font
        case color
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(ChatTheme.self, forKey: .type)
        self.font = try container.decode(AppThemeFont.self, forKey: .font)
        self.color = try container.decode(AppThemeColor.self, forKey: .color)
    }
}
