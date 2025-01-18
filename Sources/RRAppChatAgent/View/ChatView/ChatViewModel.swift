//
//  ChatViewModel.swift
//  RRAppChatAgent
//
//  Created by Raj S on 30/12/24.
//

import Foundation
import RRAppUtils
import RRAppNetwork
import Combine
import os

@MainActor
public class ChatViewModel: ObservableObject {
    
    let chatRepository: ChatRepository
    
    @Inject
    var threadRepository: ThreadsRepository
    
    @Published
    var containerData: ChatContainerData?
    
    @Published
    var messages: [ChatMessageViewModel] = []
    
    @Published
    var messageInput: ChatMessageInputViewModel = .init()
    
    @Published
    var viewState: ViewState = .idle
    
    @Published
    var navigationTitle: String?
    
    private var subscribers: Set<AnyCancellable> = .init()

    let logger = Logger(
        subsystem: "RRAppChatAgent.ChatViewModel", 
        category: "ViewModel"
    )
    
    public convenience init(input: Input) {
        self.init(
            input: input,
            chatRepository: ChatRepositoryImpl(
                streamingNetworkManager: StreamingNetworkManager()
            )
        )
    }
    
    init(input: Input, chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
        self.containerData = input.containerData
        listenToObservers()
    }
    
    func listenToObservers() {
        $containerData
            .sink { [weak self] containerData in
                guard let self else { return }
                
                if let containerData  {
                    let thread = threadRepository.currentThreads.value[containerData.assistantId]?.first(where: { $0.threadId == containerData.threadId })
                    self.navigationTitle = thread?.threadName
                } else {
                    self.navigationTitle = nil
                }
            }
            .store(in: &subscribers)
    }
}

public extension ChatViewModel {
    func fetchAllInitialMessages() async {
        guard let threadId = containerData?.threadId else { return }
        self.viewState = .fetching
        
        do {
            let allMessages = try await chatRepository.fetchAllMessage(from: threadId)
            self.messages = allMessages.map { .init(message: $0) }
        } catch let error {
            logger.error("\(error)")
        }
    }
    
    func sendMessage() async {
        guard let container = containerData,
                messageInput.isValid else { return }
        
        let message = messageInput.message
        self.messages.append(
            .init(
                id: UUID().uuidString,
                content: .text(message),
                userType: .user,
                date: Date()
            )
        )
        messageInput.message = ""
    
        self.appendMessageLoaderIfNot("Processing")
        
        do {
            let threadId = container.threadId
            _ = try await chatRepository.appendUserMessage(
                into: threadId,
                assistantId: container.assistantId,
                message: message
            )
            try await chatRepository.runAndListen(to: threadId, assistantId: container.assistantId) { [weak self] data in
                guard let self else { return }
                Task { @MainActor in
                    self.listenForRun(data: data)
                }
            }
        } catch {
            removeMessageLoader()
        }
    }
    
    private func appendMessageLoaderIfNot(_ message: String) {
        if let index = self.messages.firstIndex(where: { $0.id == "loader"}) {
            self.messages.remove(at: index)
        }
        
        self.messages.append(
            .init(
                id: "loader",
                content: .loading(message: message),
                userType: .agent,
                date: Date()
            )
        )
    }
    
    private func removeMessageLoader() {
        if let index = self.messages.firstIndex(where: { $0.id == "loader"}) {
            self.messages.remove(at: index)
        }
    }
    
    func listenForRun(data: ChatEventData) {
        print("event \(data.event.rawValue) \(data.meta)===========\n\n")
        
        switch data.event {
        case .thread:
            self.appendMessageLoaderIfNot("Processing")
        case .threadRunCreated:
            self.appendMessageLoaderIfNot("Processing")
        case .threadMessageDelta:
            self.messageInput.isReadyToSend = false
           
            self.removeMessageLoader()
            if let id = self.messages.firstIndex { $0.id == data.meta?.id } {
                let message = self.messages[id]
                var value: String = ""
                switch message.content {
                case .text(let text): value = text
                default:
                    break
                }
                value += data.meta?.delta?.content.first?.text?.value ?? ""
                self.messages[id] = .init(
                    id: message.id,
                    content: .text(value),
                    userType: .agent,
                    date: message.date
                )
            } else {
                self.messages.append(
                    .init(
                        id: data.meta?.id ?? "",
                        content: .text(
                            data.meta?.delta?.content.first?.text?.value ?? ""
                        ),
                        userType: .agent,
                        date: Date()
                    )
                )
            }
        case .threadMessageCompleted:
            self.messageInput.isReadyToSend = true
            self.removeMessageLoader()
            if let id = self.messages.firstIndex { $0.id == data.meta?.id } {
                let message = self.messages[id]
                self.messages[id] = .init(
                    id: message.id,
                    content: .text(data.meta?.content?.first?.text?.value ?? ""),
                    userType: .agent,
                    date: Date()
                )
            }
        case .threadQueued:
            self.appendMessageLoaderIfNot("Processing")
        case .threadInProgress:
            self.appendMessageLoaderIfNot("Processing")
        case .threadStepCreated:
            self.appendMessageLoaderIfNot("Processing")
        case .threadStepInProgress:
            self.appendMessageLoaderIfNot("Processing")
        case .threadMessageCreated:
            self.appendMessageLoaderIfNot("Processing")
        case .threadMessageInProgress:
            break
        case .threadRunCompleted, .threadStepCompleted:
            self.messageInput.isReadyToSend = true
        case .unknown:
            break
        }
    }
    
}

public extension ChatViewModel {
    struct Input {
        let containerData: ChatContainerData?
        
        public init(containerData: ChatContainerData?) {
            self.containerData = containerData
        }
    }
    
    class ChatContainerData {
        var threadId: String
        var assistantId: String
        
        public init(threadId: String, assistantId: String) {
            self.threadId = threadId
            self.assistantId = assistantId
        }
    }
}

extension ChatViewModel {
    enum ViewState {
        case idle
        case fetching
        case procesingLastMessage
    }
}

extension ChatMessageViewModel {
    init(message: MessageDTO) {
        let userType: ChatMessageViewModel.UserType
        switch message.role {
        case .user:
            userType = .user
        case .agent:
            userType = .agent
        case .unknown:
            userType = .agent
        }
        
        switch message.content{
        case .text(let value):
            self = .init(id: message.id,content: .text(value), userType: userType, date: message.createdAt)
        case .unknown:
            self = .init(id: message.id,content: .unknown, userType: userType, date: message.createdAt)
        }
    }
}
