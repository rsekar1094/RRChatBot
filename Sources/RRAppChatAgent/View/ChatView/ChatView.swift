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
    
    @Inject
    var theme: ChatAppTheme
    
    var body: some View {
        VStack(spacing: 0) {
            messageListView
            
            ChatMessageInputView(viewModel: viewModel.messageInput) {
                Task {
                    await viewModel.sendMessage()
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle ?? "")
        .task(id: viewModel.containerData?.threadId) {
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
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
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
        }
        .background(theme.chatColor.chat.background)
    }
}
