import Foundation
import UIKit
import AnytypeCore

public protocol SharedContentManagerProtocol: AnyObject, Sendable {
    func importAndSaveItem(item: SafeSendable<NSExtensionItem>) async -> SharedContent
    func saveSharedContent(content: SharedContent) async throws
    func getSharedContent() async throws -> SharedContent
    func clearSharedContent() async throws
}

actor SharedContentManager: SharedContentManagerProtocol {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userDefaults = UserDefaults(suiteName: TargetsConstants.appGroup)
    
    private let sharedFileStorage: SharedFileStorageProtocol
    private let sharedContentImporter: SharedContentImporterProtocol
    
    init(sharedFileStorage: SharedFileStorageProtocol, sharedContentImporter: SharedContentImporterProtocol) {
        self.sharedFileStorage = sharedFileStorage
        self.sharedContentImporter = sharedContentImporter
    }
    
    func importAndSaveItem(item safeItem: SafeSendable<NSExtensionItem>) async -> SharedContent {
        let item = safeItem.value
        try? clearSharedContent()
        let attachments = item.attachments ?? []
        let sharedContentItems = await sharedContentImporter.importData(items: SafeSendable(value: item.attachments ?? []))
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
