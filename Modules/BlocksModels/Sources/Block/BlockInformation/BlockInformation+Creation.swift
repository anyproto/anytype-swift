public extension BlockInformation {
    
    static var emptyText: BlockInformation {
        empty(content: .text(.empty(contentType: .text)))
    }
    
    static func empty(
        id: BlockId = Constants.newBlockId, content: BlockContent
    ) -> BlockInformation {
        BlockInformation(
            id: id.asAnytypeId!,
            content: content,
            backgroundColor: nil,
            alignment: .left,
            childrenIds: [],
            configurationData: BlockInformationMetadata(
                backgroundColor: .default,
                indentationStyle: content.indentationStyle(isLastChild: true),
                calloutBackgroundColor: nil
            ),
            fields: [:]
        )
    }
    
    static func emptyLink(targetId: BlockId) -> BlockInformation {
        let content: BlockContent = .link(.empty(targetBlockID: targetId))
        return BlockInformation.empty(content: content)
    }
    
}

public extension BlockInformation {
    
    enum Constants {
        public static let newBlockId = "new_block_id"
    }
    
}
