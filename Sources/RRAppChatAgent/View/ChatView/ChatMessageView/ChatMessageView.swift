//
//  ChatMessageView.swift
//  RRAppChatAgent
//
//  Created by Raj S on 30/12/24.
//

import Foundation
import SwiftUI

struct ChatMessageView: View {
    
    let viewModel: ChatMessageViewModel
    
    var body: some View {
        switch viewModel.content {
        case .text(let message):
            TypewriterText(fullText: message, characterDelay: 0.5)
                .padding()
                .foregroundColor(.white)
                .background(viewModel.userType.backgroundColor)
                .cornerRadius(8)
                .animation(.easeInOut, value: message)
        case .loading(let message):
            HStack {
                Text(message)
                
                ThreeDotsLoader()
            }
            .padding()
            .foregroundColor(.white)
            .background(viewModel.userType.backgroundColor)
            .cornerRadius(8)
        case .unknown:
            Color.clear
        }
    }
}

struct ChatMessageViewModel: Hashable, Equatable, Identifiable {
    let id: String
    let content: Content
    let userType: UserType
    
    enum Content: Hashable, Equatable {
        case text(String)
        case loading(message: String)
        case unknown
    }
    
    enum UserType: Hashable, Equatable {
        case user
        case agent
    }
}

extension ChatMessageViewModel.UserType {
    var backgroundColor: Color {
        switch self {
        case .user:
            Color.blue
        case .agent:
            Color.red
        }
    }
    
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

