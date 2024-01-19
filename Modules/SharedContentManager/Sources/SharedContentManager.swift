import Foundation
import UIKit

enum SharedContentManagerError: Error {
    case dataIsNotCreatedForImage
}

public protocol SharedContentManagerProtocol {
    func saveSharedContent(content: [SharedContent]) throws
    func getSharedContent() throws -> [SharedContent]
    func clearSharedContent() throws
    func saveFileToGroup(url: URL) throws -> URL
    func saveImageToGroup(image: UIImage) throws -> URL
}

final class SharedContentManager: SharedContentManagerProtocol {
    private lazy var encoder = JSONEncoder()
    private lazy var decoder = JSONDecoder()
    private lazy var userDefaults = UserDefaults(suiteName: TargetsConstants.appGroup)
    
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
        try deleteFilesFromGroup()
    }
    
    func saveFileToGroup(url: URL) throws -> URL {
        let filePath = findFreeFileName(originalURL: url)
        try FileManager.default.copyItem(at: url, to: filePath)
        return filePath
    }
    
    func saveImageToGroup(image: UIImage) throws -> URL {
        let filePath = containerPath().appendingPathExtension("\(UUID().uuidString).jpg")
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw SharedContentManagerError.dataIsNotCreatedForImage
        }
        try data.write(to: filePath)
        return filePath
    }
    
    // MARK: - Private
    
    private func deleteFilesFromGroup() throws {
        let containerFolder = containerPath()
        
        // TODO: Delete all folders
        let fileURLs = try FileManager.default.contentsOfDirectory(at: containerFolder, includingPropertiesForKeys: nil)
        for fileURL in fileURLs {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    private func containerPath() -> URL {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: TargetsConstants.appGroup
        ) else {
            fatalError()
        }
        
        return containerURL.appendingPathComponent("Library/Caches")
    }
    
    private func findFreeFileName(originalURL: URL) -> URL {
        let filePath = containerPath().appendingPathComponent(originalURL.lastPathComponent)
        guard FileManager.default.fileExists(atPath: filePath.relativePath) else {
            return filePath
        }
        let fileName = filePath.deletingPathExtension().lastPathComponent
        let fileExtension = filePath.pathExtension
        for i in 1...100 {
            let newFilePath = filePath
                .deletingLastPathComponent()
                .appendingPathComponent("\(fileName)-\(i)")
                .appendingPathExtension(fileExtension)
            if !FileManager.default.fileExists(atPath: newFilePath.relativePath) {
                return newFilePath
            }
        }
        
        // UUID
        let newFilePath = filePath
            .deletingLastPathComponent()
            .appendingPathComponent("\(fileName)-\(UUID().uuidString)")
            .appendingPathExtension(fileExtension)
        return newFilePath
    }
}
