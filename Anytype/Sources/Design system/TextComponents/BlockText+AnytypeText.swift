import Services

extension BlockText {
    func anytypeText(document: some BaseDocumentProtocol) -> UIKitAnytypeText {
        AttributedTextConverter.asModel(
            document: document,
            text: text,
            marks: marks,
            style: contentType
        )
    }
}
