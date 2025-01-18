//
//  ChatMessageView.swift
//  RRAppChatAgent
//
//  Created by Raj S on 30/12/24.
//

import Foundation
import SwiftUI
import RRAppUtils

struct ChatMessageView: View {
    
    @Inject
    var theme: ChatAppTheme
    
    let viewModel: ChatMessageViewModel
    
    var body: some View {
        switch viewModel.content {
        case .text(let message):
            VStack(alignment: .trailing, spacing: 0) {
                TypewriterText(
                    fullText: message, characterDelay: 0.5
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(foregroundColor)
                .font(messageFont)
                
                Text(viewModel.dateInfo)
                    .foregroundColor(foregroundColor)
                    .font(theme.chatFont.chat.info)
                    .opacity(0.75)
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(8)
            .animation(.easeInOut, value: message)
        case .loading(let message):
            HStack {
                Text(LocalizedStringKey(message))
                
                ThreeDotsLoader()
            }
            .padding()
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(8)
        case .unknown:
            Color.clear
        }
    }

    var backgroundColor: Color {
        switch viewModel.userType {
        case .agent:
            return theme.chatColor.chat.agent.background
        case .user:
            return theme.chatColor.chat.user.background
        }
    }
    
    var foregroundColor: Color {
        switch viewModel.userType {
        case .user:
            return theme.chatColor.chat.user.text
        case .agent:
            return theme.chatColor.chat.agent.text
        }
    }
    
    var messageFont: Font {
        return theme.chatFont.chat.message
    }
}

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



#Preview {
    VStack {
        ChatMessageView(
            viewModel: .init(
                id: "",
                content: .loading(
                    message: "The Tesla cancellation process involves several key points:\n\n1. **Order Deposit**: When you place an order for a custom-ordered Tesla vehicle, they begin the production or matching process for the vehicle. If you cancel the order or breach the agreement, Tesla may retain the order deposit as liquidated damages, unless prohibited by law【4:0†teslaterms.pdf】.\n\n2. **Timing**: Up until the vehicle enters production or is matched to a vehicle, you may make changes to your vehicle configuration. However, any changes could potentially result in price adjustments【4:0†teslaterms.pdf】.\n\n3. **Order Cancellations**:\n   - Orders can be canceled and deposits retained if Tesla believes the order is intended for resale or if it is not in good faith.\n   - Tesla may also cancel an order and refund your order deposit if they discontinue a product, feature, or option after the order is placed【4:1†teslaterms.pdf】【4:3†teslaterms.pdf】.\n\n4. **Refunds** for Quebec Deliveries: The order deposit is refundable until vehicle delivery for orders in Quebec【4:0†teslaterms.pdf】. \n\nTherefore, canceling a Tesla order may involve losing your initial deposit unless otherwise specified, like in Quebec. It is important to understand these terms fully as they can impact your financial obligations in the case of an order cancellation."
                ),
                userType: .agent,
                date: Date()
            )
        )
    }
}
