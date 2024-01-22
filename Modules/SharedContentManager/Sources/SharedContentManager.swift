import Foundation
import UIKit

public protocol SharedContentManagerProtocol: AnyObject {
    func importAndSaveItems(items: [NSItemProvider]) async -> [SharedContent]
    func saveSharedContent(content: [SharedContent]) throws
    func getSharedContent() throws -> [SharedContent]
    func clearSharedContent() throws
}

final class SharedContentManager: SharedContentManagerProtocol {
    private lazy var encoder = JSONEncoder()
    private lazy var decoder = JSONDecoder()
    private lazy var userDefaults = UserDefaults(suiteName: TargetsConstants.appGroup)
    
    private let sharedFileStorage: SharedFileStorageProtocol
    private let sharedContentImporter: SharedContentImporterProtocol
    
    init(sharedFileStorage: SharedFileStorageProtocol, sharedContentImporter: SharedContentImporterProtocol) {
        self.sharedFileStorage = sharedFileStorage
        self.sharedContentImporter = sharedContentImporter
    }
    
    func importAndSaveItems(items: [NSItemProvider]) async -> [SharedContent] {
        try? clearSharedContent()
        let sharedItems = await sharedContentImporter.importData(items: items)
        try? saveSharedContent(content: sharedItems)
        return sharedItems
    }
    
    func saveSharedContent(content: [SharedContent]) throws {
        let sharedData = try encoder.encode(content)
        let jsonString = String(data: sharedData, encoding: .utf8)
        
        userDefaults?.set(jsonString, forKey: SharedUserDefaultsKey.sharingExtension)
        userDefaults?.synchronize()
    }
    
    func getSharedContent() throws -> [SharedContent] {
        guard let jsonString = userDefaults?.string(forKey: SharedUserDefaultsKey.sharingExtension),
                let data = jsonString.data(using: .utf8) else {
            return []
        }
        
        let sharedContent = try decoder.decode([SharedContent].self, from: data)
        
        return sharedContent
    }
    
    func clearSharedContent() throws {
        userDefaults?.removeObject(forKey: SharedUserDefaultsKey.sharingExtension)
        try sharedFileStorage.clearStorage()
    }
}
