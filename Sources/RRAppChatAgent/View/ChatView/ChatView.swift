//
//  ChatView.swift
//  RRAppChatAgent
//
//  Created by Raj S on 28/12/24.
//

import Foundation
import SwiftUI
import RRAppTheme
import RRAppUtils
import SwiftUI

struct ChatView: View {
    
    @ObservedObject
    var viewModel: ChatViewModel
    
    var body: some View {
        VStack {
            messageListView
            
            ChatMessageInputView(viewModel: viewModel.messageInput) {
                Task {
                    await viewModel.sendMessage()
                }
            }
        }
        .task(id: viewModel.input.threadId) {
            await viewModel.fetchAllInitialMessages()
        }
    }
}

extension ChatView {
    @ViewBuilder
    var messageListView: some View {
        ScrollView {
            ScrollViewReader { reader in
                ForEach(viewModel.messages, id: \.self) { message in
                    ChatMessageView(viewModel: message)
                        .padding(message.userType.edgePadding, 50)
                        .frame(maxWidth: .infinity, alignment: message.userType.alignment)
                        .id(message.id)
                }
                .onChange(of: viewModel.messages) { oldMessage, newMessages in
                    if oldMessage.isEmpty {
                        reader.scrollTo(newMessages.last?.id, anchor: .bottom)
                    } else {
                        withAnimation {
                            reader.scrollTo(newMessages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
