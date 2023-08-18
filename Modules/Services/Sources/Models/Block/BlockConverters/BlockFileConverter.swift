import ProtobufMessages

public extension Anytype_Model_Block.Content.File {
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


public extension BlockFile {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .file(.with {
            $0.hash = metadata.hash
            $0.name = metadata.name
            $0.type = contentType.asMiddleware
            $0.mime = metadata.mime
            $0.size = metadata.size
            $0.addedAt = 0
            $0.state = state.asMiddleware
            $0.style = .auto
        })
    }
}

