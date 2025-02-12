import Foundation
import UniformTypeIdentifiers
import UIKit
import AnytypeCore

enum ShareExtensionError: Error {
    case parseFailure
    case copyFailure
}

public protocol SharedContentImporterProtocol: AnyObject, Sendable {
    func importData(items: SafeSendable<[NSItemProvider]>) async -> [SharedContentItem]
}

final class SharedContentImporter: SharedContentImporterProtocol {
    
    private let typeText = UTType.plainText
    private let typeURL = UTType.url
    private let typeFileUrl = UTType.fileURL
    private let typeImage = UTType.image
    private let typeVisualContent = UTType.audiovisualContent
    
    private let sharedFileStorage: SharedFileStorageProtocol
    
    private let formatter = DateFormatter.photoDateTimeFormatter
    
    init(sharedFileStorage: SharedFileStorageProtocol) {
        self.sharedFileStorage = sharedFileStorage
    }
    
    // MARK: - SharedContentImporterProtocol
    
    func importData(items: SafeSendable<[NSItemProvider]>) async -> [SharedContentItem] {
        let items = items.value
        let importDate = Date()
        return await withSortedTaskGroup(of: SharedContentItem?.self, returning: [SharedContentItem].self) { taskGroup in
            items.enumerated().forEach { index, itemProvider in
                let safeItemProvider = itemProvider.sendable()
                // Should be sort by UTType hierarchy from child to parent
                if itemProvider.hasItemConformingToTypeIdentifier(typeFileUrl.identifier) {
                    taskGroup.addTask { try? await self.handleFileUtl(itemProvider: safeItemProvider.value) }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeImage.identifier) {
                    taskGroup.addTask { try? await self.handleImage(itemProvider: safeItemProvider.value, index: index, importDate: importDate) }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeVisualContent.identifier) {
                    taskGroup.addTask { try? await self.handleAudioAndVideo(itemProvider: safeItemProvider.value) }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeURL.identifier) {
                    taskGroup.addTask { try? await self.handleURL(itemProvider: safeItemProvider.value) }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeText.identifier) {
                    taskGroup.addTask { try? await self.handleText(itemProvider: safeItemProvider.value) }
                }
            }
            
            return await taskGroup.waitResult().compactMap { $0 }
        }
    }
    
    // MARK: - Private
    
    private func handleText(itemProvider: NSItemProvider) async throws -> SharedContentItem {
        let item = try await itemProvider.loadItem(forTypeIdentifier: typeText.identifier)
        guard let text = item as? NSString else { throw ShareExtensionError.parseFailure }
        return .text(text as String)
    }
    
    private func handleURL(itemProvider: NSItemProvider) async throws -> SharedContentItem {
        let item = try await itemProvider.loadItem(forTypeIdentifier: typeURL.identifier)
        guard let url = item as? NSURL else { throw ShareExtensionError.parseFailure }
        return .url(url as URL)
    }
    
    private func handleFileUtl(itemProvider: NSItemProvider) async throws -> SharedContentItem {
        let item = try await itemProvider.loadItem(forTypeIdentifier: typeFileUrl.identifier)
        guard let fileURL = item as? NSURL else { throw ShareExtensionError.copyFailure }
        let groupFileUrl = try sharedFileStorage.saveFileToGroup(url: fileURL as URL)
        return .file(groupFileUrl)
    }
    
    private func handleImage(itemProvider: NSItemProvider, index: Int, importDate: Date) async throws -> SharedContentItem {
        let item = try await itemProvider.loadItem(forTypeIdentifier: typeImage.identifier)
        if let fileURL = item as? NSURL {
            let groupFileUrl = try sharedFileStorage.saveFileToGroup(url: fileURL as URL)
            return .file(groupFileUrl)
        }
        if let image = item as? UIImage {
            let name = "PHOTO-\(formatter.string(from: importDate))-\(index)"
            let groupFileUrl = try sharedFileStorage.saveImageToGroup(image: image, name: name)
            return .file(groupFileUrl)
        }
        throw ShareExtensionError.parseFailure
    }
    
    private func handleAudioAndVideo(itemProvider: NSItemProvider) async throws -> SharedContentItem {
        let item = try await itemProvider.loadItem(forTypeIdentifier: typeVisualContent.identifier)
        guard let fileURL = item as? NSURL else { throw ShareExtensionError.parseFailure }
        let groupFileUrl = try sharedFileStorage.saveFileToGroup(url: fileURL as URL)
        return .file(groupFileUrl)
    }
}

