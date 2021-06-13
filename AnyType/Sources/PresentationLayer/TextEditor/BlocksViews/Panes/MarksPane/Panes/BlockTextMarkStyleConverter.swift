enum BlockTextMarkStyleConverter {
    static func convert(_ style: BlockTextView.MarkStyle) -> BlockActionHandler.ActionType.TextAttributesType? {
        switch style {
        case .bold: return .bold
        case .italic: return .italic
        case .strikethrough: return .strikethrough
        case .keyboard: return .keyboard

        default: return nil
        }
    }
}
