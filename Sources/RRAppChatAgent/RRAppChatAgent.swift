// The Swift Programming Language
// https://docs.swift.org/swift-book
import RRAppUtils
import RRAppTheme
import RRAppNetwork

public struct RRAppChatAgent {
    
    public static func load() {
        loadTheme()
        loadNetworkManager()
        Resolver.shared.add(ThreadsRepositoryImpl(), key: String(reflecting: ThreadsRepository.self))
    }
}

private extension RRAppChatAgent {
    static func loadTheme() {
        do {
            let models: [ChatAppTheme] = try JSONManager.fetchArrayData(fileName: "Theme", from: .module)
            if let model = models.first {
                Resolver.shared.add(model,key: String(reflecting: Theme.self))
                Resolver.shared.add(model,key: String(reflecting: ChatAppTheme.self))
            }
        } catch {
            print("\(error)")
        }
    }
    
    static func loadNetworkManager() {
        let config = ChatConfigurationImpl()
        Resolver.shared.add(config, key: String(reflecting: Config.self)) // For Base Network
        
        Resolver.shared.add(URLSessionNetworkManager(),key: String(reflecting: NetworkService.self))
    }
}
