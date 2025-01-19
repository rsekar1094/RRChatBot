//
//  ThreadCellView.swift
//  RRAppChatAgent
//
//  Created by Raj S on 19/01/25.
//

import Foundation
import SwiftUI

// MARK: - ThreadCellView
struct ThreadCellView: View {
    
    let viewModel: ThreadCellViewModel
    let isSelected: Bool
    
    @EnvironmentObject
    var themeManager: ThemeManager

    var theme: ChatAppTheme { return themeManager.current }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text(viewModel.primaryText)
                    .lineLimit(1)
                    .foregroundStyle(primaryColor)
                    .font(theme.chatFont.thread.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(viewModel.info)
                    .foregroundStyle(infoColor)
                    .font(theme.chatFont.thread.info)
            }
            
            Text(viewModel.secondaryText)
                .foregroundStyle(secondaryColor)
                .font(theme.chatFont.thread.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
               
        }
        .padding()
        .background(
            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                .fill(backgroundColor)
        )
    }
    
    var primaryColor: Color {
        let thread = theme.chatColor.thread
        return isSelected ? thread.selected.primaryText : thread.unSelected.primaryText
    }
    
    var secondaryColor: Color {
        let thread = theme.chatColor.thread
        return isSelected ? thread.selected.secondaryText : thread.unSelected.secondaryText
    }
    
    var infoColor: Color {
        let thread = theme.chatColor.thread
        return isSelected ? thread.selected.infoText : thread.unSelected.infoText
    }
    
    var backgroundColor: Color {
        let thread = theme.chatColor.thread
        return isSelected ? thread.selected.background : thread.unSelected.background
    }
}

