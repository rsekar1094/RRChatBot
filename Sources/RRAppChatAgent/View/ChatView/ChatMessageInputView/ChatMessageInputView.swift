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

@Observable
class ChatMessageInputViewModel {
    var message: String = ""
    var isValid: Bool { !message.isEmpty }
    var isReadyToSend: Bool = true
}

struct ChatMessageInputView: View {
    
    @Inject
    var theme: Theme
   
    @State
    var viewModel: ChatMessageInputViewModel
    
    let sendCompletion: (() -> Void)
    
    var body: some View {
        HStack {
            TextField("Ask something...", text: $viewModel.message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .vertical])
            
            Button(
                action: {
                    guard viewModel.isReadyToSend else { return }
                    sendCompletion()
                }, label: {
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding()
                        .foregroundStyle(Color.red)
                }
            )
           
        }
    }
}
