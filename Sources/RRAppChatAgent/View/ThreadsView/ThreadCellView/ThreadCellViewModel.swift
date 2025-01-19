//
//  ThreadCellViewModel.swift
//  RRAppChatAgent
//
//  Created by Raj S on 19/01/25.
//

import Foundation

// MARK: - ThreadCellViewModel
struct ThreadCellViewModel: Identifiable {
    let id: String
    let primaryText: String
    let secondaryText: String
    let info: String
}

extension ThreadCellViewModel {
    init(model: ThreadsDTO) {
        self.id = model.threadId
        self.info = Date(timeIntervalSince1970: model.lastUpdatedAt).info
        self.primaryText = model.threadName
        self.secondaryText = model.lastMessageSneakPeak
    }
}
