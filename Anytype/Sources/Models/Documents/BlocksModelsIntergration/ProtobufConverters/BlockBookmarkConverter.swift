import ProtobufMessages
import BlocksModels

extension Anytype_Model_Block.Content.Bookmark {
    var blockConten: BlockContent? {
        type.asModel.flatMap(
            {
                .bookmark(
                    .init(
                        source: url,
                        title: title,
                        theDescription: description_p,
                        imageHash: imageHash,
                        faviconHash: faviconHash,
                        type: $0,
                        targetObjectID: targetObjectID,
                        state: state.asModel
                    )
                )
            }
        )
    }
}

extension BlockBookmark {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .bookmark(
            .init(
                url: source,
                title: title,
                description_p: theDescription,
                imageHash: imageHash,
                faviconHash: faviconHash,
                type: type.asMiddleware,
                targetObjectID: targetObjectID,
                state: state.asMiddleware
            )
        )
    }
}
