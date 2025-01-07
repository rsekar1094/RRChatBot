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
    var theme: Theme
   
    @ObservedObject
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
            .disabled(!viewModel.isValid)
            .opacity(viewModel.isValid ? 1 : 0.2)
           
        }
    }
}
