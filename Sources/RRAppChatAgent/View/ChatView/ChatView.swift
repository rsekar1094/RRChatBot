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

public struct ChatView: View {
    
    @StateObject
    private var viewModel = ChatViewModel(input: .init(threadId: "thread_PgcUZ5qTqE73GiQS2MxZkbY7"))
    
    public init() {}
    
    public var body: some View {
        VStack {
            messageListView
            
            ChatMessageInputView(viewModel: viewModel.messageInput) {
                Task {
                    await viewModel.sendMessage()
                }
            }
        }
        .task {
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
