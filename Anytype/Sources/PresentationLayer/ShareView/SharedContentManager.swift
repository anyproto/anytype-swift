import Foundation

protocol SharedContentManagerProtocol {
    func saveSharedContent(content: [SharedContent]) throws
    func getSharedContent() throws -> [SharedContent]
    func clearSharedContent()
}

enum SharedContent: Codable {
    case text(AttributedString)
    case url(URL)
    case image(URL)
}

final class SharedContentManager: SharedContentManagerProtocol {
    private lazy var encoder = JSONEncoder()
    private lazy var decoder = JSONDecoder()
    private lazy var userDefaults = UserDefaults(suiteName: TargetsConstants.appGroup)
    
    func saveSharedContent(content: [SharedContent]) throws {
        let sharedData = try JSONEncoder().encode(content)
        let jsonString = String(data: sharedData, encoding: .utf8)
        
        userDefaults?.set(jsonString, forKey: SharedUserDefaultsKey.sharingExtension)
    }
    
    func getSharedContent() throws -> [SharedContent] {
        guard let jsonString = userDefaults?.string(forKey: SharedUserDefaultsKey.sharingExtension),
                let data = jsonString.data(using: .utf8) else {
            return []
        }
        
        let sharedContent = try decoder.decode([SharedContent].self, from: data)
        
        return sharedContent
    }
    
    func clearSharedContent() {
        userDefaults?.removeObject(forKey: SharedUserDefaultsKey.sharingExtension)
    }
}
