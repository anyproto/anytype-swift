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
    
    static func file(fileDetails: ObjectDetails) -> BlockInformation {
        let content = BlockContent.file(
            BlockFile(
                metadata: FileMetadata(
                    name: fileDetails.name,
                    size: Int64(fileDetails.sizeInBytes ?? 0),
                    targetObjectId: fileDetails.id,
                    mime: fileDetails.fileMimeType,
                    addedAt: 0
                ),
                contentType: fileDetails.layoutValue.fileContentType,
                state: .done
            )
        )
        return BlockInformation.empty(content: content)
    }
}

fileprivate extension DetailsLayout {
    var fileContentType: FileContentType {
        switch self {
        case .file:
            return .file
        case .image:
            return .image
        case .audio:
            return .audio
        case .video:
            return .video
        default:
            return .none
        }
    }
}
