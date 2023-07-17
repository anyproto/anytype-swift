import Services

extension BlockText {
    func anytypeText(document: BaseDocumentProtocol) -> UIKitAnytypeText {
        AttributedTextConverter.asModel(
            document: document,
            text: text,
            marks: marks,
            style: contentType
        )
    }
}
