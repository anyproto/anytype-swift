import ProtobufMessages
import AnytypeCore

public extension Anytype_Model_Block.Content.Bookmark {
    var blockConten: BlockContent? {
        type.asModel.flatMap(
            {
                .bookmark(
                    .init(
                        source: AnytypeURL(string: url),
                        title: title,
                        theDescription: description_p,
                        imageObjectId: imageHash,
                        faviconObjectId: faviconHash,
                        type: $0,
                        targetObjectID: targetObjectID,
                        state: state.asModel
                    )
                )
            }
        )
    }
}

public extension BlockBookmark {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .bookmark(.with {
            $0.url = source?.absoluteString ?? ""
            $0.title = title
            $0.description_p = theDescription
            $0.imageHash = imageHash
            $0.faviconHash = faviconHash
            $0.type = type.asMiddleware
            $0.targetObjectID = targetObjectID
            $0.state = state.asMiddleware
        })
    }
}
