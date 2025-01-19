//
//  AssistantListCellView.swift
//  RRAppChatAgent
//
//  Created by Raj S on 19/01/25.
//

import Foundation
import SwiftUI

// MARK: - AssistantListCellView
struct AssistantListCellView: View {
    
    let viewModel: AssistantListCellViewModel
    let isSelected: Bool
    var theme: ChatAppTheme { return themeManager.current }
    
    @EnvironmentObject
    var themeManager: ThemeManager
    
    var body: some View {
        if isSelected {
            contentView
                .background(
                    RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                        .fill(theme.chatColor.agent.selected.background)
                )
                .padding(.horizontal)
        } else {
            contentView
                .padding(.horizontal)
        }
    }
}

private extension AssistantListCellView {
    
    @ViewBuilder
    var contentView: some View {
        VStack {
            if let url = viewModel.imageUrl {
                AsyncCachedImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Text(viewModel.name)
                    .lineLimit(1)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.white)
                    .padding()
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black)
                    )
            }
            
            Text(viewModel.name)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .font(.system(size: 10))
                .foregroundStyle(textColor)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 5)
    }
}

private extension AssistantListCellView {
    var textColor: Color {
        let agent = theme.chatColor.agent
        return isSelected ? agent.selected.text : agent.unselected.text
    }
}

// MARK: - AssistantListCellViewModel
struct AssistantListCellViewModel: Identifiable {
    let name: String
    let imageUrl: URL?
    let id: String
}
