import BlocksModels
import Foundation

extension BlockFile {
    func originalPath(with blockId: BlockId) -> URL {
        FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent(blockId)
            .appendingPathComponent(metadata.name)
    }

    func previewPath(with blockId: BlockId) -> URL {
        FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent(blockId)
            .appendingPathComponent("preview")
            .appendingPathComponent(metadata.name)
    }
}
