public extension BlockInformation {
    func flatChildrenTree(container: InfoContainerProtocol) -> [BlockInformation] {
        ChildrenInfoTreeBuilder(container: container, root: self).flatList()
    }
    
    var isToggled: Bool {
        ToggleStorage.shared.isToggled(blockId: id.value)
    }

    func toggle() {
        ToggleStorage.shared.toggle(blockId: id.value)
    }
    
    var kind: BlockKind {
        switch content {
        case .smartblock, .layout:
            return .meta
        case .text, .file, .divider, .bookmark, .link, .featuredRelations, .relation, .dataView, .unsupported:
            return .block
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
    
    func headerLayout(container: InfoContainerProtocol) -> BlockInformation? {
        container.children(of: id.value).first { info in
            info.content == .layout(.init(style: .header))
        }
    }
}
