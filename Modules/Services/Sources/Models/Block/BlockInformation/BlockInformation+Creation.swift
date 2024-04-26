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
            configurationData: BlockInformationMetadata(
                backgroundColor: .default,
                indentationStyle: content.indentationStyle(isLastChild: true),
                calloutBackgroundColor: nil
            ),
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
    
    static func file(fileDetails: FileDetails) -> BlockInformation {
        let content = BlockContent.file(
            BlockFile(
                metadata: FileMetadata(
                    name: fileDetails.fileName,
                    size: Int64(fileDetails.sizeInBytes),
                    targetObjectId: fileDetails.id,
                    mime: fileDetails.fileMimeType,
                    addedAt: 0
                ),
                contentType: fileDetails.fileContentType,
                state: .done
            )
        )
        return BlockInformation.empty(content: content)
    }
}
