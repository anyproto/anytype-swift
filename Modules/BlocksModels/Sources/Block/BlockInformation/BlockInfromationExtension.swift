public extension BlockInformation {
    var isToggled: Bool {
        ToggleStorage.shared.isToggled(blockId: id)
    }

    func toggle() {
        ToggleStorage.shared.toggle(blockId: id)
    }
    
    var kind: BlockKind {
        switch content {
        case .smartblock, .layout:
            return .meta
        case .text, .file, .divider, .bookmark, .link, .featuredRelations, .relation, .dataView, .unsupported:
            return .block
        }
    }
    
    static var emptyText: BlockInformation {
        empty(content: .text(.empty(contentType: .text)))
    }
    
    static func empty(
        blockId: BlockId = "", content: BlockContent
    ) -> BlockInformation {
        BlockInformation(
            id: blockId,
            content: content,
            backgroundColor: nil,
            alignment: .left,
            childrenIds: [],
            fields: [:]
        )
    }
    
    var isTextAndEmpty: Bool {
        switch content {
        case .text(let textData):
            switch textData.contentType {
            case .code:
                return false
            default:
                return textData.text.isEmpty
            }
        default:
            return false
        }
    }
}
