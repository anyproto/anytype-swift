public extension BlockInformation {
    
    static var emptyText: BlockInformation {
        empty(content: .text(.empty(contentType: .text)))
    }
    
    static func empty(
        id: BlockId = "", content: BlockContent
    ) -> BlockInformation {
        BlockInformation(
            id: id,
            content: content,
            backgroundColor: nil,
            horizontalAlignment: .left,
            childrenIds: [],
            configurationData: BlockInformationMetadata(backgroundColor: .default),
            fields: [:]
        )
    }
    
    static func emptyLink(targetId: BlockId) -> BlockInformation {
        let content: BlockContent = .link(
            .init(
                targetBlockID: targetId,
                appearance: .init(iconSize: .small, cardStyle: .text, description: .none, relations: [])
            )
        )

        return BlockInformation.empty(content: content)
    }
    
    static func bookmark(targetId: BlockId) -> BlockInformation {
        let content: BlockContent = .bookmark(.empty(targetObjectID: targetId))
        return BlockInformation.empty(content: content)
    }
}
