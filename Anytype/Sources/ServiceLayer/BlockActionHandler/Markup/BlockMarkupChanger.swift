import AnytypeCore
import BlocksModels

final class BlockMarkupChanger: BlockMarkupChangerProtocol {
    
    var handler: EditorActionHandlerProtocol!
    
    private let document: BaseDocumentProtocol
    private let documentId: String
    private lazy var blockUpdater: BlockUpdater? = {
        guard let container = document.rootModel else { return nil }
        return BlockUpdater(container)
    }()
    
    init(
        document: BaseDocumentProtocol,
        documentId: String
    ) {
        self.document = document
        self.documentId = documentId
    }
    
    func toggleMarkup(
        _ markup: BlockHandlerActionType.TextAttributesType,
        attributedText: NSAttributedString,
        for blockId: BlockId,
        in range: NSRange
    ) {
        guard let (model, content) = blockData(blockId: blockId) else { return }
        
        let restrictions = BlockRestrictionsFactory().makeTextRestrictions(
            for: content.contentType
        )
        let markupCalculator = MarkupStateCalculator(
            attributedText: attributedText,
            range: range,
            restrictions: restrictions,
            alignment: nil
        )
        let markupState = markupCalculator.state(for: markup)
        guard markupState != .disabled else { return }
        
        let shouldApplyMarkup = markupState == .notApplied
        switch markup {
        case .bold:
            applyAndStore(
                .bold(shouldApplyMarkup),
                block: model,
                content: content,
                attributedText: attributedText,
                range: range
            )
        case .italic:
            applyAndStore(
                .italic(shouldApplyMarkup),
                block: model,
                content: content,
                attributedText: attributedText,
                range: range
            )
        case .strikethrough:
            applyAndStore(
                .strikethrough(shouldApplyMarkup),
                block: model,
                content: content,
                attributedText: attributedText,
                range: range
            )
        case .keyboard:
            applyAndStore(
                .keyboard(shouldApplyMarkup),
                block: model,
                content: content,
                attributedText: attributedText,
                range: range
            )
        }
    }

    func setLink(
        _ link: URL?,
        attributedText: NSAttributedString,
        for blockId: BlockId,
        in range: NSRange
    ) {
        guard let (model, content) = blockData(blockId: blockId) else { return }
        
        let restrictions = BlockRestrictionsFactory().makeTextRestrictions(
            for: content.contentType
        )
        guard restrictions.canApplyOtherMarkup else { return }
        
        applyAndStore(
            .link(link),
            block: model,
            content: content,
            attributedText: attributedText,
            range: range
        )
    }
    
    private func blockData(blockId: BlockId) -> (BlockModelProtocol, BlockText)? {
        guard let model = document.rootModel?.blocksContainer.model(id: blockId) else {
            anytypeAssertionFailure("Can't find block with id: \(blockId)")
            return nil
        }
        guard case let .text(content) = model.information.content else {
            anytypeAssertionFailure("Unexpected block type \(model.information.content)")
            return nil
        }
        return (model, content)
    }
    
    private func applyAndStore(
        _ action: MarkStyleAction,
        block: BlockModelProtocol,
        content: BlockText,
        attributedText: NSAttributedString,
        range: NSRange
    ) {
        // Ignore changing markup in empty string 
        guard range.length != 0 else { return }

        let result = apply(action, attrText: attributedText, content: content, range: range)
        store(attributedString: result, block: block, content: content)
    }
    
    private func apply(
        _ action: MarkStyleAction,
        attrText: NSAttributedString,
        content: BlockText,
        range: NSRange
    ) -> NSAttributedString {
        let modifier = MarkStyleModifier(
            attributedText: NSMutableAttributedString(
                attributedString: attrText
            ),
            anytypeFont: content.contentType.uiFont
        )
        modifier.apply(action, range: range)
        return NSAttributedString(attributedString: modifier.attributedString)
    }
    
    private func store(
        attributedString: NSAttributedString,
        block: BlockModelProtocol,
        content: BlockText
    ) {
        handler.handleAction(
            .textView(
                action: .changeText(attributedString),
                block: block
            ),
            blockId: block.information.id
        )
    }
}
