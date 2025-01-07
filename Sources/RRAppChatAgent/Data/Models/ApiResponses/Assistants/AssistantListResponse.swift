//
//  AssistantListResponse.swift
//  RRAppChatAgent
//
//  Created by Raj S on 06/01/25.
//

import Foundation
struct AssistantListResponse: Decodable {
    let data: [Assistant]
    
    struct Assistant: Decodable {
        let id: String
        let name: String
        let created_at: TimeInterval
        let metadata: [String: String]
    }
}
