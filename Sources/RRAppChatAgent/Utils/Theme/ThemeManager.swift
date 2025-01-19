//
//  ThemeManager.swift
//  RRAppChatAgent
//
//  Created by Raj S on 19/01/25.
//

import Foundation
import SwiftUI
import RRAppUtils

// MARK: - ThemeManager
class ThemeManager: ObservableObject {
    
    @Published
    var current: ChatAppTheme
    private let availableThemes: [ChatAppTheme]

    init(current: ChatAppTheme) {
        self.current = current
        
        let models: [ChatAppTheme] = (try? JSONManager.fetchArrayData(fileName: "Theme", from: .module)) ?? []
        self.availableThemes = models
    }
    
    init() {
        let selectedType = UserDefaults.standard.string(forKey: "theme") ?? ChatTheme.whatsapp.rawValue
        guard let models: [ChatAppTheme] = try? JSONManager.fetchArrayData(fileName: "Theme", from: .module),
              let model = models.first(where: { $0.type.rawValue == selectedType }) else {
            fatalError()
        }
        
        self.availableThemes = models
        self.current = model
    }
    
    func setCurrentTheme(to theme: ChatTheme) {
        guard let model = availableThemes.first(where: { $0.type == theme }) else {
            fatalError()
        }
        
        current = model
        UserDefaults.standard.set(theme.rawValue, forKey: "theme")
    }
}
