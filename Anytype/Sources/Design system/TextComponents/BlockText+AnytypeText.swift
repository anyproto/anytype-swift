import BlocksModels

extension BlockText {
    var anytypeText: UIKitAnytypeText {
        return AttributedTextConverter.asModel(text: text, marks: marks, style: contentType)
    }
}
