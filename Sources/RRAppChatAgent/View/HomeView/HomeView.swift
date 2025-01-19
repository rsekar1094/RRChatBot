//
//  HomeView.swift
//  RRAppChatAgent
//
//  Created by Raj S on 05/01/25.
//

import Foundation
import SwiftUI
import Combine
import RRAppUtils

// MARK: - HomeView
public struct HomeView: View {
    
    @StateObject
    var viewModel: HomeViewModel = .init()
    
    @State
    var splitViewVisibiluty: NavigationSplitViewVisibility = .all
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @State
    var leftSafeAreaWidth: CGFloat = 30
    
    @State
    var navigationPath: NavigationPath = .init()
    
    @StateObject
    private var themeManager = ThemeManager()
    
    public init() {}
    
    public var body: some View {
        contentView
        .navigationSplitViewStyle(.balanced)
        .environmentObject(themeManager)
    }
    
    @ViewBuilder
    public var contentView: some View {
        #if os(watchOS)
        contentViewInNavigationView
        #else
        if horizontalSizeClass == .compact {
            contentViewInNavigationView
                .tint(themeManager.current.color.primary)
        } else {
            contentViewInsideSplitView
                .tint(themeManager.current.color.primary)
        }
        #endif
    }
}

// MARK: - HomeView + NavigationView
private extension HomeView {
    var contentViewInNavigationView: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    AssistantsListView(viewModel: viewModel.assistantsViewModel)
                        .frame(width: proxy.size.width * 0.3)
                    
                    ThreadsView(viewModel: viewModel.threadsViewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(viewModel.threadsViewModel.$selectedThreadId) { value in
                guard let value else { return }
                
                navigationPath.append(value)
            }
            .navigationDestination(for: String.self) { _ in
                ChatView(viewModel: viewModel.chatViewModel)
            }
        }
    }
}

// MARK: - HomeView + SplitView
private extension HomeView {
    var contentViewInsideSplitView: some View {
        NavigationSplitView(
            columnVisibility: $splitViewVisibiluty,
            sidebar: {
                GeometryReader { proxy in
                    AssistantsListView(viewModel: viewModel.assistantsViewModel)
                        .onChange(of: proxy.safeAreaInsets.leading) { old, new in
                            leftSafeAreaWidth = new
                        }
                }
                .background(themeManager.current.chatColor.agent.unselected.background)
                .navigationSplitViewColumnWidth(150 + leftSafeAreaWidth)
            },
            content: {
                ThreadsView(viewModel: viewModel.threadsViewModel)
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            },
            detail: {
                ChatView(viewModel: viewModel.chatViewModel)
            }
        )
    }
}
