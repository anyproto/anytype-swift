import BlocksModels

extension BlockText {
    func anytypeText(using detailsStorage: ObjectDetailsStorageProtocol) -> UIKitAnytypeText {
        AttributedTextConverter.asModel(
            text: text,
            marks: marks,
            style: contentType,
            detailsStorage: detailsStorage
        )
    }
}
