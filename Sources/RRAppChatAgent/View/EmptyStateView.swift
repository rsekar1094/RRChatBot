//
//  EmptyStateView.swift
//  RRAppChatAgent
//
//  Created by Raj S on 19/01/25.
//

import Foundation
import SwiftUI

struct EmptyStateView: View {
    let viewModel: EmptyStateViewModel
    
    @EnvironmentObject
    var themeManager: ThemeManager
        
    var theme: ChatAppTheme { return themeManager.current }
    
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: viewModel.imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(theme.chatColor.primary)
            
            Text(viewModel.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(viewModel.message)
                .font(.body)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
    }
}

struct EmptyStateViewModel {
    let imageName: String
    let title: String
    let message: String
}

#Preview {
    EmptyStateView(viewModel: .init(imageName: "figure.snowboarding", title: "No Threads", message: "Create your first thread by clicking the plus button in the top right corner."))
        .environmentObject(ThemeManager())
}
