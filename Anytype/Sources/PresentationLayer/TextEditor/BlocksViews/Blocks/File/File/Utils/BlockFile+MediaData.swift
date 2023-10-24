import Services
import Foundation

extension BlockFile {
    var mediaData: BlockFileMediaData {
        BlockFileMediaData(
            size: ByteCountFormatter.fileFormatter.string(fromByteCount: metadata.size),
            name: metadata.name,
            iconImageName: FileIconBuilder.convert(mime: metadata.mime, fileName: metadata.name)
        )
    }
}
