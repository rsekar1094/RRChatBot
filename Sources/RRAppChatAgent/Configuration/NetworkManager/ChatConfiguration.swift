//
//  ChatConfiguration.swift
//  RRAppChatAgent
//
//  Created by Raj S on 30/12/24.
//

import Foundation
import RRAppNetwork

protocol ChatConfiguration: Config {
    var assistantId: String { get }
}

struct ChatConfigurationImpl: ChatConfiguration {
    init() {}
    
    let apiBasePath: String = "https://api.openai.com"
    let appToken: String  = "" // Use your open.ai token
    let assistantId: String = "asst_iUCqdJytXQ3dQ8uWIKzXFRBq"
}
