//
//  AppThemeFont.swift
//  RRAppChatAgent
//
//  Created by Raj S on 25/12/24.
//

import Foundation
import SwiftUI
import RRAppTheme

struct AppThemeFont: Decodable, ThemeFont {
    let headline: Font
    let body: Font
    
    enum CodingKeys: String, CodingKey {
        case headline
        case body
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        body = try container.decode(Font.self, forKey: .body)
        headline = try container.decode(Font.self, forKey: .headline)
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
