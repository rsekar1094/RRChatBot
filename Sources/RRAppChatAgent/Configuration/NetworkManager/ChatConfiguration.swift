//
//  ChatConfiguration.swift
//  RRAppChatAgent
//
//  Created by Raj S on 30/12/24.
//

import Foundation
import RRAppNetwork

struct ChatConfigurationImpl: Config {
    init() {}
    
    let apiBasePath: String = "https://api.openai.com"
    let appToken: String  = "" // Use your open.ai token
}
