import BlocksModels

final class BlockFileContextualMenuBuilder {
    static func contextualMenu(fileData: BlockFile) -> ContextualMenu {
        switch fileData.state {
        case .done:
            return .init(title: "", children: [
                .init(action: .addBlockBelow),
                .init(action: .duplicate),
                .init(action: .download),
                .init(action: .replace),
                .init(action: .delete)
            ])
        default:
            return .init(title: "", children: [
                .init(action: .addBlockBelow),
                .init(action: .duplicate),
                .init(action: .delete)
            ])
        }
    }
}
