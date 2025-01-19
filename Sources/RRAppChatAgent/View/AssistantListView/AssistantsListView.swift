//
//  AssistantsListView.swift
//  RRAppChatAgent
//
//  Created by Raj S on 19/01/25.
//

import Foundation
import SwiftUI

// MARK: - AssistantsListView
struct AssistantsListView: View {
    
    @ObservedObject
    var viewModel: AssistantsListViewModel
    
    @EnvironmentObject
    var themeManager: ThemeManager
    
    var theme: ChatAppTheme { return themeManager.current }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.assistants) { assistant in
                    AssistantListCellView(
                        viewModel: assistant,
                        isSelected: assistant.id == viewModel.selectedAssistantId
                    )
                    .onTapGesture {
                        viewModel.didSelectedAssistant(with: assistant.id)
                    }
                }
            }
        }
        .background(theme.chatColor.agent.unselected.background)
    }
}
