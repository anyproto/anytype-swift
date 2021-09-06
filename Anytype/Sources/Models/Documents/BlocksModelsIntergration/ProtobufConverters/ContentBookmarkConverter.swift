import ProtobufMessages
import BlocksModels

class ContentBookmarkConverter {
    func blockType(_ from: Anytype_Model_Block.Content.Bookmark) -> BlockContent? {
        return BlocksModelsParserBookmarkTypeEnumConverter.asModel(from.type).flatMap(
            {
                .bookmark(
                    .init(url: from.url, title: from.title, theDescription: from.description_p, imageHash: from.imageHash, faviconHash: from.faviconHash, type: $0)
                )
            }
        )
    }
    
    func middleware(_ from: BlockBookmark) -> Anytype_Model_Block.OneOf_Content {
        .bookmark(
            .init(
                url: from.url,
                title: from.title,
                description_p: from.theDescription,
                imageHash: from.imageHash,
                faviconHash: from.faviconHash,
                type: BlocksModelsParserBookmarkTypeEnumConverter.asMiddleware(from.type)
            )
        )
    }
}
