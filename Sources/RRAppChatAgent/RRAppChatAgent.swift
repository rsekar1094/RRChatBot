// The Swift Programming Language
// https://docs.swift.org/swift-book
import RRAppUtils
import RRAppTheme
import RRAppNetwork

public struct RRAppChatAgent {
    
    public static func load() {
        loadTheme()
        loadNetworkManager()
    }
}

private extension RRAppChatAgent {
    static func loadTheme() {
        do {
            let models: [AppTheme] = try JSONManager.fetchArrayData(fileName: "Theme", from: .module)
            if let model = models.first {
                Resolver.shared.add(model,key: String(reflecting: Theme.self))
            }
        } catch {
            
        }
    }
    
    static func loadNetworkManager() {
        let config = ChatConfigurationImpl()
        Resolver.shared.add(config, key: String(reflecting: Config.self)) // For Base Network
        Resolver.shared.add(config, key: String(reflecting: ChatConfiguration.self)) // For chat related
        
        Resolver.shared.add(URLSessionNetworkManager(),key: String(reflecting: NetworkService.self))
    }
}
