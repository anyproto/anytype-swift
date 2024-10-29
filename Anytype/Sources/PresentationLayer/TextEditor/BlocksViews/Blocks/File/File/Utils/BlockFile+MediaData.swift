import Services
import Foundation

extension BlockFile {
    func mediaData(documentId: String, spaceId: String) -> BlockFileMediaData {
        BlockFileMediaData(
            targetObjectId: metadata.targetObjectId,
            documentId: documentId,
            spaceId: spaceId
        )
    }
}
