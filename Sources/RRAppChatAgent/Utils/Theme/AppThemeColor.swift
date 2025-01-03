//
//  AppThemeColor.swift
//  RRAppChatAgent
//
//  Created by Raj S on 25/12/24.
//

import Foundation
import SwiftUI
import RRAppTheme

struct AppThemeColor: Decodable, ThemeColor {
    let primary: Color
    let secondary: Color
    let error: Color
    
    enum CodingKeys: String, CodingKey {
        case primary
        case secondary
        case error
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        primary = try container.decode(Color.self, forKey: .primary)
        secondary = try container.decode(Color.self, forKey: .secondary)
        error = try container.decode(Color.self, forKey: .error)
    }
}

extension Color: @retroactive Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexValue = try container.decode(String.self)
        self = Color(uiColor: UIColor(hex: hexValue))
    }
}
