import Services
import Foundation

extension BlockFile {
    func mediaData(documentId: String) -> BlockFileMediaData {
        BlockFileMediaData(
            targetObjectId: metadata.targetObjectId,
            documentId: documentId
        )
    }
}
