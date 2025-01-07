//
//  File.swift
//  RRAppChatAgent
//
//  Created by Raj S on 05/01/25.
//

import Foundation
import SwiftUI
import RRMediaView
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var assistantsViewModel: AssistantsListViewModel = .init(assistantRepository: AssistantRepositoryImpl())
    @Published var threadsViewModel: ThreadsViewModel?
    @Published var chatViewModel: ChatViewModel?
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init() {
        listenToAssistantObservers()
    }
    
    func listenToAssistantObservers() {
        assistantsViewModel.$selectedAssistantId
            .sink { [weak self] selectedAssistantId in
                guard let self, let selectedAssistantId else { return }
                
                if self.threadsViewModel?.assistantId != selectedAssistantId {
                    self.threadsViewModel = ThreadsViewModel(assistantId: selectedAssistantId)
                    self.listenToThreadObservers(for: selectedAssistantId)
                }
                
            }
            .store(in: &cancellables)
    }
    
    func listenToThreadObservers(for assistantId: String) {
        threadsViewModel?.$selectedThreadId
            .sink { [weak self] selectedThreadId in
                guard let self,
                        let selectedThreadId else {
                    self?.chatViewModel = nil
                    return
                }
                
                self.chatViewModel = ChatViewModel(
                    input: .init(
                        threadId: selectedThreadId,
                        assistantId: assistantId
                    )
                )
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
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView(
            columnVisibility: $splitViewVisibiluty,
            sidebar: {
                GeometryReader { proxy in
                    AssistantsListView(viewModel: viewModel.assistantsViewModel)
                        .onChange(of: proxy.safeAreaInsets.leading) { old, new in
                            leftSafeAreaWidth = new
                            print("leftSafeAreaWidth \(new) \(old) \(leftSafeAreaWidth)")
                        }
                }
                .navigationSplitViewColumnWidth(150 + leftSafeAreaWidth)
                .background(Color.black)
            },
            content: {
                if let threadsViewModel = viewModel.threadsViewModel {
                    ThreadsView(viewModel: threadsViewModel)
                        .navigationSplitViewColumnWidth(250)
                } else {
                    Color.red
                }
            },
            detail: {
                if let chatViewModel = viewModel.chatViewModel {
                    ChatView(viewModel: chatViewModel)
                } else {
                    Color.blue
                }
            }
        )
        .navigationSplitViewStyle(.balanced)
    }
}

struct AssistantsListView: View {
    @ObservedObject
    var viewModel: AssistantsListViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.assistants) { assistant in
                    AssistantListCellView(viewModel: assistant, isSelected: assistant.id == viewModel.selectedAssistantId)
                        .onTapGesture {
                            viewModel.didSelectedAssistant(with: assistant.id)
                        }
                }
            }
        }
    }
}

struct AssistantListCellView: View {
    let viewModel: AssistantListCellViewModel
    let isSelected: Bool
    
    var body: some View {
        contentView
            .overlay {
                RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                    .stroke(isSelected ? Color.white : Color.red, lineWidth: isSelected ? 4 : 2)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 5)
    }
    
    @ViewBuilder
    var contentView: some View {
        if let url = viewModel.imageUrl {
            MediaView(
                mediaType: .image(.remote(url)),
                size: .both(.init(width: 100, height: 100))
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Text(viewModel.name)
                .font(.system(size: 10))
                .foregroundStyle(Color.white)
                .frame(width: 100, height: 100)
        }
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


extension URL: MediaSourceURL {
    public var url: URL {
        return self
    }
    
    
}
