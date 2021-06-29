extension CustomTextView.ContextMenuAction {
    
    var asActionType: BlockHandlerActionType.TextAttributesType {
        switch self {
        case .bold:
            return .bold
        case .italic:
            return .italic
        case .strikethrough:
            return .strikethrough
        }
    }
}
