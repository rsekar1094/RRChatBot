//
//  ChatMessageInputView.swift
//  RRAppChatAgent
//
//  Created by Raj S on 01/01/25.
//

import Foundation
import SwiftUI
import RRAppTheme
import RRAppUtils

class ChatMessageInputViewModel: ObservableObject {
    @Published var message: String = ""
    @Published var isReadyToSend: Bool = true
    
    var isValid: Bool { !message.isEmpty }
}

struct ChatMessageInputView: View {
    
    @Inject
    var theme: ChatAppTheme
   
    @ObservedObject
    var viewModel: ChatMessageInputViewModel
    
    let sendCompletion: (() -> Void)
    
    var body: some View {
        HStack {
            
            TextField(text: $viewModel.message) {
                Text("Ask something...")
                    .font(theme.chatFont.chat.messageInput.placeholder)
                    .foregroundStyle(theme.chatColor.chat.textInput.placeholder)
            }
            .foregroundStyle(theme.chatColor.chat.textInput.text)
            .font(theme.chatFont.chat.messageInput.text)
            .padding([.leading, .vertical])
            
            Button(
                action: {
                    guard viewModel.isValid, viewModel.isReadyToSend else { return }
                    sendCompletion()
                }, label: {
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(theme.color.primary)
                        .padding()
                }
            )
            .opacity(viewModel.isValid ? 1 : 0.2)
           
        }
        .background(theme.chatColor.chat.textInput.background)
    }
}
