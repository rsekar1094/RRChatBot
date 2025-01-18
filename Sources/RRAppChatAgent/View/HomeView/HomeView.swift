//
//  File.swift
//  RRAppChatAgent
//
//  Created by Raj S on 05/01/25.
//

import Foundation
import SwiftUI
import Combine
import RRAppUtils

@MainActor
class HomeViewModel: ObservableObject {
    @Published var assistantsViewModel: AssistantsListViewModel = .init(assistantRepository: AssistantRepositoryImpl())
    @Published var threadsViewModel = ThreadsViewModel(assistantId: nil)
    @Published var chatViewModel: ChatViewModel = ChatViewModel(input: .init(containerData: nil))
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init() {
        listenToAssistantObservers()
        listenToThreadObservers()
    }
    
    func listenToAssistantObservers() {
        assistantsViewModel.$selectedAssistantId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedAssistantId in
                guard let self, let selectedAssistantId else { return }
                
                if self.threadsViewModel.assistantId != selectedAssistantId {
                    self.chatViewModel.containerData = nil
                    self.threadsViewModel.assistantId = selectedAssistantId
                }
                
            }
            .store(in: &cancellables)
    }
    
    func listenToThreadObservers() {
        threadsViewModel.$selectedThreadId
            .sink { [weak self] selectedThreadId  in
                guard let self,
                      let selectedThreadId,
                      let selectedAssistantId = self.assistantsViewModel.selectedAssistantId else {
                    self?.chatViewModel.containerData = nil
                    return
                }
                
                self.chatViewModel.containerData = .init(threadId: selectedThreadId, assistantId: selectedAssistantId)
            }
            .store(in: &cancellables)
    }
}

public struct HomeView: View {
    
    @StateObject
    var viewModel: HomeViewModel = .init()
    
    @State
    var splitViewVisibiluty: NavigationSplitViewVisibility = .all
    
    @State
    var leftSafeAreaWidth: CGFloat = 30
    
    @Inject
    var theme: ChatAppTheme
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView(
            columnVisibility: $splitViewVisibiluty,
            sidebar: {
                GeometryReader { proxy in
                    AssistantsListView(viewModel: viewModel.assistantsViewModel)
                        .onChange(of: proxy.safeAreaInsets.leading) { old, new in
                            leftSafeAreaWidth = new
                        }
                }
                .navigationSplitViewColumnWidth(150 + leftSafeAreaWidth)
                .background(theme.chatColor.agent.unselected.background)
            },
            content: {
                ThreadsView(viewModel: viewModel.threadsViewModel)
                    .navigationSplitViewColumnWidth(250)
            },
            detail: {
                ChatView(viewModel: viewModel.chatViewModel)
            }
        )
        .navigationSplitViewStyle(.balanced)
    }
}

struct AssistantsListView: View {
    @ObservedObject
    var viewModel: AssistantsListViewModel
    
    @Inject
    var theme: ChatAppTheme
    
    @State
    var showThemeSelectSheet: Bool = false
    
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
        .sheet(isPresented: $showThemeSelectSheet) {
            VStack {
                ForEach(ChatTheme.allCases) { item in
                    Text(item.rawValue.localizedCapitalized)
                        .padding()
                        .onTapGesture {
                            RRAppChatAgent.loadTheme(type: item)
                            showThemeSelectSheet = false
                        }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    action: {
                        showThemeSelectSheet = true
                    }, label: {
                        Image(systemName: "gear.circle.fill")
                    }
                )
                .foregroundStyle(theme.color.primary)
            }
        }
    }
}

struct AssistantListCellView: View {
    let viewModel: AssistantListCellViewModel
    let isSelected: Bool
    
    @Inject
    var theme: ChatAppTheme
    
    var body: some View {
        if isSelected {
            contentView
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                        .fill(theme.chatColor.agent.selected.background)
                )
        } else {
            contentView
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        VStack {
            if let url = viewModel.imageUrl {
                AsyncImage(url: url) { result in
                    result.image?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
                    .frame(width: 100, height: 100)
                    .overlay {
                        Text(viewModel.name)
                            .font(.system(size: 10))
                            .foregroundStyle(Color.white)
                    }
            }
            
            Text(viewModel.name)
                .font(.system(size: 10))
                .foregroundStyle(textColor)
                .padding(.bottom, 8)
        }
    }
    
    var textColor: Color {
        let agent = theme.chatColor.agent
        return isSelected ? agent.selected.text : agent.unselected.text
    }
}

struct AssistantListCellViewModel: Identifiable {
    let name: String
    let imageUrl: URL?
    let id: String
}

@MainActor
class AssistantsListViewModel: ObservableObject {
    
    @Published
    var assistants: [AssistantListCellViewModel] = []
    
    @Published
    var selectedAssistantId: String?
    
    let assistantRepository: AssistantRepository
    
    init(assistantRepository: AssistantRepository) {
        self.assistantRepository = assistantRepository
        Task {
            await fetchAllAssistants()
        }
    }
    
    func fetchAllAssistants() async {
        do {
            let assistants = try await assistantRepository.fetchAllAssistants()
            self.assistants = assistants.map { .init(name: $0.name, imageUrl: $0.imageUrl, id: $0.id) }
            if let id = assistants.first?.id {
                self.didSelectedAssistant(with: id)
            }
        } catch {
            
        }
    }
    
    func didSelectedAssistant(with id: String) {
        selectedAssistantId = id
    }
}
