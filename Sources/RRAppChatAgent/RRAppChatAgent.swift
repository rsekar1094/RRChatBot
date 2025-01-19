// The Swift Programming Language
// https://docs.swift.org/swift-book
import RRAppUtils
import RRAppTheme
import RRAppNetwork

public struct RRAppChatAgent {
    
    public static func load() {
        loadNetworkManager()
        Resolver.shared.add(ThreadsRepositoryImpl(), key: String(reflecting: ThreadsRepository.self))
    }
}

extension RRAppChatAgent {
    
    static func loadNetworkManager() {
        let config = ChatConfigurationImpl()
        Resolver.shared.add(config, key: String(reflecting: Config.self)) // For Base Network
        
        Resolver.shared.add(URLSessionNetworkManager(),key: String(reflecting: NetworkService.self))
    }
}
