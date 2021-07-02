import BlocksModels

final class BlockFileContextualMenuBuilder {
    static func contextualMenu(fileData: BlockFile) -> ContextualMenu {
        switch fileData.state {
        case .done:
            return .init(title: "", children: [
                .init(action: .addBlockBelow),
                .init(action: .delete),
                .init(action: .duplicate),
                .init(action: .download),
                .init(action: .replace)
            ])
        default:
            return .init(title: "", children: [
                .init(action: .addBlockBelow),
                .init(action: .delete),
                .init(action: .duplicate),
            ])
        }
    }
}
