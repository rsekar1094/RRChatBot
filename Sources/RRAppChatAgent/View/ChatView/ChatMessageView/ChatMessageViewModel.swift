//
//  ChatMessageViewModel.swift
//  RRAppChatAgent
//
//  Created by Raj S on 19/01/25.
//

import Foundation
import SwiftUI

// MARK: - ChatMessageViewModel
struct ChatMessageViewModel: Hashable, Equatable, Identifiable {
    let id: String
    let content: Content
    let userType: UserType
    let date: Date
    
    enum Content: Hashable, Equatable {
        case text(String)
        case loading(message: String)
        case unknown
    }
    
    enum UserType: Hashable, Equatable {
        case user
        case agent
    }
    
    var dateInfo: String {
        return date.info
    }
}

extension ChatMessageViewModel.UserType {
    var alignment: Alignment {
        switch self {
        case .user:
            return .leading
        case .agent:
            return .trailing
        }
    }
    
    var edgePadding: Edge.Set {
        switch self {
        case .user:
            return [.trailing]
        case .agent:
            return [.leading]
        }
    }
}

