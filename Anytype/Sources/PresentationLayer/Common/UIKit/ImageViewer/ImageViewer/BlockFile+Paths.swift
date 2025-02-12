import Services
import Foundation

extension FileManager {
    static func originalPath(objectId: String, fileName: String) -> URL {
        FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent("file-\(objectId)")
            .appendingPathComponent(fileName)
    }

    static func previewPath(objectId: String, fileName: String) -> URL {
        FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent(objectId)
            .appendingPathComponent("preview")
            .appendingPathComponent(fileName)
    }
}
