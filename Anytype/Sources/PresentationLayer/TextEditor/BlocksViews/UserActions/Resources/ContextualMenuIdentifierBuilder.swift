struct ContextualMenuIdentifierBuilder {
    static func identifier(for action: ContextualMenuAction) -> String {
        switch action {
        case .addBlockBelow: return ".addBlockBelow"
        case .delete: return ".delete"
        case .duplicate: return ".duplicate"
        case .moveTo: return ".moveTo"
        case .turnIntoPage: return ".turnIntoPage"
        case .style: return ".style"
        case .color: return ".color"
        case .backgroundColor: return ".backgroundColor"
        case .download: return ".specifc(.download)"
        case .replace: return ".replace"
        case .addCaption: return ".addCaption"
        case .rename: return ".rename"
        }
    }
    
    static func action(for identifier: String) -> ContextualMenuAction? {
        self.identifiersAndActions[identifier]
    }
    
    private static var identifiersAndActions: [String: ContextualMenuAction] = .init(uniqueKeysWithValues: [
        .addBlockBelow,
        .delete,
        .duplicate,
        .moveTo,
        .turnIntoPage,
        .style,
        .color,
        .backgroundColor,
        .download,
        .replace,
        .addCaption,
        .rename
    ].map({(Self.identifier(for: $0), $0)}))
}
