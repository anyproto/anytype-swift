import Services
import Foundation

extension BlockFile {
    func originalPath(blockId: String, fileName: String) -> URL {
        FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent("file-\(blockId)")
            .appendingPathComponent(fileName)
    }

    func previewPath(blockId: String, fileName: String) -> URL {
        FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent(blockId)
            .appendingPathComponent("preview")
            .appendingPathComponent(fileName)
    }
}
