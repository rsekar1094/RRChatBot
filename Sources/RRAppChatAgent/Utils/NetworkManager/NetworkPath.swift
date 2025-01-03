//
//  NetworkPath.swift
//  RRAppChatAgent
//
//  Created by Raj S on 30/12/24.
//

import Foundation

// MARK: - NetworkPath
struct NetworkPath { }

// MARK: - NetworkPath + Thread
extension NetworkPath {
    enum Thread {
        case create
        
        var path: String {
            switch self {
            case .create:
                return "v1/threads"
            }
        }
    }
}

// MARK: - NetworkPath + Message
extension NetworkPath {
    enum Message {
        case create(threadId: String)
        case listAll(threadId: String)
        
        var path: String {
            switch self {
            case .create(let threadId):
                return "v1/threads/\(threadId)/messages"
            case .listAll(let threadId):
                return "v1/threads/\(threadId)/messages"
            }
        }
    }
}

// MARK: - NetworkPath + Run
extension NetworkPath {
    enum Run {
        case createThreadAndRun
        case create(threadId: String)
        
        var path: String {
            switch self {
            case .createThreadAndRun:
                return "v1/threads/runs"
            case .create(let threadId):
                return "v1/threads/\(threadId)/runs"
            }
        }
    }
}
