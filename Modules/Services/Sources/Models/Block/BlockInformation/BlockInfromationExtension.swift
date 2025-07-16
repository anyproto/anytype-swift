import AnytypeCore

public extension BlockInformation {
    func flatChildrenTree(container: InfoContainerProtocol) -> [BlockInformation] {
        ChildrenInfoTreeBuilder(container: container, root: self).flatList()
    }
    
    var isToggled: Bool {
        ToggleStorage.shared.isToggled(blockId: id)
    }

    func toggle() {
        ToggleStorage.shared.toggle(blockId: id)
    }
    
    var kind: BlockKind {
        switch content {
        case .smartblock, .layout, .tableRow, .tableColumn:
            return .meta
        case .text, .file, .divider, .bookmark, .link, .featuredRelations, .relation, .dataView, .table,
                .tableOfContents, .widget, .unsupported, .chat, .embed:
            return .block
        }
    }
    
    var textContent: BlockText? {
        switch content {
        case .text(let blockText):
            return blockText
        default:
            anytypeAssertionFailure("Couldn't retrieve blockText content from BlockInformation")
            return nil
        }
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
    
    var isText: Bool {
        switch content {
        case .text:
            return true
        default:
            return false
        }
    }

    var isFeaturedRelations: Bool {
        switch content {
        case .featuredRelations:
            return true
        default:
            return false
        }
    }
    
    var isWidget: Bool {
        switch content {
        case .widget:
            return true
        default:
            return false
        }
    }
    
    var isFile: Bool {
        switch content {
        case .file:
            return true
        default:
            return false
        }
    }
    
    func headerLayout(container: InfoContainerProtocol) -> BlockInformation? {
        container.children(of: id).first { info in
            info.content == .layout(.init(style: .header))
        }
    }
}
