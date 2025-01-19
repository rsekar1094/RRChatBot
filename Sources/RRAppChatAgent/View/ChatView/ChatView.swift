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

// MARK: - ChatView
struct ChatView: View {
    
    @ObservedObject
    var viewModel: ChatViewModel
    
    @EnvironmentObject
    var themeManager: ThemeManager
    
    @State
    var showThemeSelectSheet: Bool = false
    
    var theme: ChatAppTheme { return themeManager.current }
    
    var body: some View {
        #if os(watchOS)
        if #available(watchOS 11.0, *) {
            contentView
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        } else {
            contentView
        }
        #else
        if #available(iOS 18.0, *) {
            contentView
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        } else {
            contentView
        }
        #endif
        
    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            if viewModel.viewState == .fetching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            
            if viewModel.viewState != .fetching && viewModel.messages.isEmpty {
                EmptyStateView(
                    viewModel: .init(
                        imageName: "sailboat",
                        title: "No Messages",
                        message: "Start your conversation by typing a message.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                messageListView
            }
            
            ChatMessageInputView(viewModel: viewModel.messageInput) {
                Task {
                    await viewModel.sendMessage()
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showThemeSelectSheet) {
            VStack {
                ForEach(ChatTheme.allCases) { item in
                    Text(item.rawValue.localizedCapitalized)
                        .padding()
                        .onTapGesture {
                            themeManager.setCurrentTheme(to: item)
                            showThemeSelectSheet = false
                        }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        showThemeSelectSheet = true
                    }, label: {
                        Image(systemName: "gear.circle")
                    }
                )
            }
        }
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
