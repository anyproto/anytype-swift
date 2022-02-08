import ProtobufMessages
import BlocksModels

extension Anytype_Model_Block.Content.File {
    var blockContent: BlockContent? {
        guard let state = state.asModel else { return nil }
        return FileContentType(type).flatMap { type in
            .file(
                .init(
                    metadata: .init(name: name, size: size, hash: hash, mime: mime, addedAt: addedAt),
                    contentType: type,
                    state: state
                )
            )
        }
    }
}


extension BlockFile {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .file(
            .init(
                hash: metadata.hash,
                name: metadata.name,
                type: contentType.asMiddleware,
                mime: metadata.mime,
                size: metadata.size,
                addedAt: 0,
                state: state.asMiddleware,
                style: .auto
            )
        )
    }
  
}

