import Foundation
import UIKit

public protocol SharedContentManagerProtocol: AnyObject {
    func importAndSaveItem(item: NSExtensionItem) async -> SharedContent
    func saveSharedContent(content: SharedContent) throws
    func getSharedContent() throws -> SharedContent
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
    
    func importAndSaveItem(item: NSExtensionItem) async -> SharedContent {
        try? clearSharedContent()
        let attachments = item.attachments ?? []
        let sharedContentItems = await sharedContentImporter.importData(items: item.attachments ?? [])
        let sortedItems = sharedContentItems.filter { $0.isText } + sharedContentItems.filter { !$0.isText }
            
        let debugInfo = SharedContentDebugInfo(
            items: attachments.map { SharedContentDebugItem(mimeTypes: $0.registeredTypeIdentifiers.map { $0.description }) }
        )
        let sharedContent = SharedContent(title: item.attributedTitle?.string, items: sortedItems, debugInfo: debugInfo)
        try? saveSharedContent(content: sharedContent)
        return sharedContent
    }
    
    func saveSharedContent(content: SharedContent) throws {
        let sharedData = try encoder.encode(content)
        let jsonString = String(data: sharedData, encoding: .utf8)
        
        userDefaults?.set(jsonString, forKey: SharedUserDefaultsKey.sharingExtension)
        userDefaults?.synchronize()
    }
    
    func getSharedContent() throws -> SharedContent {
        guard let jsonString = userDefaults?.string(forKey: SharedUserDefaultsKey.sharingExtension),
                let data = jsonString.data(using: .utf8) else {
            throw SharedContentManagerError.common
        }
        
        let sharedContent = try decoder.decode(SharedContent.self, from: data)
        
        return sharedContent
    }
    
    func clearSharedContent() throws {
        userDefaults?.removeObject(forKey: SharedUserDefaultsKey.sharingExtension)
        try sharedFileStorage.clearStorage()
    }
}
