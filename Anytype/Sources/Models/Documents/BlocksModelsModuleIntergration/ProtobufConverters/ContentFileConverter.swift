import ProtobufMessages
import BlocksModels

class ContentFileConverter {
    func blockType(_ from: Anytype_Model_Block.Content.File) -> BlockContent? {
        guard let state = BlockFileStateConverter.asModel(from.state) else { return nil }
        return BlockContentFileContentTypeConverter.asModel(from.type).flatMap(
            {.file(
                .init(
                    metadata: .init(
                        name: from.name,
                        size: from.size,
                        hash: from.hash,
                        mime: from.mime,
                        addedAt: from.addedAt
                    ),
                    contentType: $0,
                    state: state
                )
            )}
        )
    }
    
    func middleware(_ from: BlockFile) -> Anytype_Model_Block.OneOf_Content? {
        let state = BlockFileStateConverter.asMiddleware(from.state)
        let metadata = from.metadata
        
        return BlockContentFileContentTypeConverter.asMiddleware(from.contentType).flatMap(
            {.file(
                .init(
                    hash: metadata.hash,
                    name: metadata.name,
                    type: $0,
                    mime: metadata.mime,
                    size: metadata.size,
                    addedAt: 0,
                    state: state
                )
            )}
        )
    }
  
}

