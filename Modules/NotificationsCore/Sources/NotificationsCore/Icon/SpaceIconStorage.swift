import UIKit
import AnytypeCore
import Factory

public protocol SpaceIconStorageProtocol: AnyObject {
    func addIcon(spaceId: String, icon: UIImage)
    func iconLocalUrl(forSpaceId spaceId: String) -> URL?
    func removeAll()
}

final class SpaceIconStorage: SpaceIconStorageProtocol {
    
    private let sharedPath = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: TargetsConstants.appGroup)?
        .appendingPathComponent("SpaceIconStorageCache", isDirectory: true)
    
    func addIcon(spaceId: String, icon: UIImage) {
        guard let sharedPath else {
            anytypeAssertionFailure("sharedPath not found")
            return
        }
        
        try? FileManager.default.createDirectory(at: sharedPath, withIntermediateDirectories: true)
        let iconPath = sharedPath.appendingPathComponent(makeIconName(forSpaceId: spaceId), isDirectory: false)
        let data = icon.pngData()
        
        do {
            try data?.write(to: iconPath)
        } catch {
            anytypeAssertionFailure("add icon error", info: ["error": "\(error)"])
        }
    }
    
    func iconLocalUrl(forSpaceId spaceId: String) -> URL? {
        guard let sharedPath else {
            anytypeAssertionFailure("sharedPath not found")
            return nil
        }
        
        let iconPath = sharedPath.appendingPathComponent(makeIconName(forSpaceId: spaceId), isDirectory: false)
        return FileManager.default.fileExists(atPath: iconPath.path()) ? iconPath : nil
    }
    
    func removeAll() {
        guard let sharedPath else {
            anytypeAssertionFailure("sharedPath not found")
            return
        }
        
        try? FileManager.default.removeItem(at: sharedPath)
    }
    
    private func makeIconName(forSpaceId spaceId: String) -> String {
        return "spaceIcon-\(spaceId).png"
    }
}

public extension Container {
    
    var spaceIconStorage: Factory<SpaceIconStorageProtocol> {
        self { SpaceIconStorage() }.singleton
    }
    
}
