import BlocksModels

final class BlockFileContextualMenuBuilder {
    static func contextualMenu(fileData: BlockFile) -> [ContextualMenu] {
        switch fileData.state {
        case .done:
            return [ .addBlockBelow, .duplicate, .download, .replace, .delete ]
        default:
            return [ .addBlockBelow, .duplicate, .delete ]
        }
    }
}
