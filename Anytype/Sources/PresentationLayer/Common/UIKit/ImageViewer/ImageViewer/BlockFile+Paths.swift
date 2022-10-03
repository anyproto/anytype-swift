import BlocksModels
import Foundation

extension BlockFile {
    var originalPath: URL {
        FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent(metadata.name)
            .appendingPathExtension(metadata.name.fileExtension())
    }

    var previewPath: URL {
        FileManager
            .default
            .temporaryDirectory
            .appendingPathComponent(metadata.name + "-preview")
            .appendingPathExtension(metadata.name.fileExtension())
    }
}

private extension String {
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
