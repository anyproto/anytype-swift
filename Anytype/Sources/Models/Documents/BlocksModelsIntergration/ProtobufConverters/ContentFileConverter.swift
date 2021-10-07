import ProtobufMessages
import BlocksModels

class ContentFileConverter {
    func blockType(_ from: Anytype_Model_Block.Content.File) -> BlockContent? {
        guard let state = BlockFileStateConverter.asModel(from.state) else { return nil }
        return FileContentType(from.type).flatMap { type in
            .file(
                .init(
                    metadata: .init(
                        name: from.name,
                        size: from.size,
                        hash: from.hash,
                        mime: from.mime,
                        addedAt: from.addedAt
                    ),
                    contentType: type,
                    state: state
                )
            )
        }
    }
    
    func middleware(_ from: BlockFile) -> Anytype_Model_Block.OneOf_Content? {
        let state = BlockFileStateConverter.asMiddleware(from.state)
        let metadata = from.metadata
        
        return .file(
            .init(
                hash: metadata.hash,
                name: metadata.name,
                type: from.contentType.asMiddleware,
                mime: metadata.mime,
                size: metadata.size,
                addedAt: 0,
                state: state
            )
        )
    }
  
}

