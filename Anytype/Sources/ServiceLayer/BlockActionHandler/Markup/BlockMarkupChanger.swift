import AnytypeCore
import BlocksModels

final class BlockMarkupChanger {
    
    private let document: BaseDocumentProtocol
    private let documentId: String
    private let textService: BlockActionsServiceTextProtocol
    private lazy var blockUpdater: BlockUpdater? = {
        guard let container = document.rootModel else { return nil }
        return BlockUpdater(container)
    }()
    
    init(
        document: BaseDocumentProtocol,
        documentId: String,
        textService: BlockActionsServiceTextProtocol
    ) {
        self.document = document
        self.documentId = documentId
        self.textService = textService
    }
    
    private func blockContent(blockId: BlockId) -> BlockText? {
        guard let model = document.rootModel?.blocksContainer.model(id: blockId) else {
            anytypeAssertionFailure("Can't find block with id: \(blockId)")
            return nil
        }
        guard case let .text(content) = model.information.content else {
            anytypeAssertionFailure("Unexpected block type \(model.information.content)")
            return nil
        }
        return content
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
        blockId: BlockId,
        content: BlockText
    ) {
        let middlewareString = AttributedTextConverter.asMiddleware(attributedText: attributedString)
        var content = content
        content.marks = middlewareString.marks
        content.text = middlewareString.text

        blockUpdater?.update(entry: blockId) { model in
            var model = model
            model.information.content = .text(content)
        }
        textService.setText(
            contextID: documentId,
            blockID: blockId,
            middlewareString: middlewareString
        )
    }
    
    private func applyAndStore(
        _ action: MarkStyleAction,
        blockId: BlockId,
        content: BlockText,
        attributedText: NSAttributedString,
        range: NSRange
    ) {
        // Ignore changing markup in empty string 
        guard range.length != 0 else { return }

        let result = apply(
            action,
            attrText: attributedText,
            content: content,
            range: range
        )
        store(
            attributedString: result,
            blockId: blockId,
            content: content
        )
        document.eventHandler.handle(
            events: PackOfEvents(
                localEvents: [.setText(blockId: blockId, text: result.string)]
            )
        )
    }
}

extension BlockMarkupChanger: BlockMarkupChangerProtocol {
    
    func toggleMarkup(
        _ markup: BlockHandlerActionType.TextAttributesType,
        attributedText: NSAttributedString,
        for blockId: BlockId,
        in range: NSRange
    ) {
        guard let content = blockContent(blockId: blockId) else { return }
        
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
                blockId: blockId,
                content: content,
                attributedText: attributedText,
                range: range
            )
        case .italic:
            applyAndStore(
                .italic(shouldApplyMarkup),
                blockId: blockId,
                content: content,
                attributedText: attributedText,
                range: range
            )
        case .strikethrough:
            applyAndStore(
                .strikethrough(shouldApplyMarkup),
                blockId: blockId,
                content: content,
                attributedText: attributedText,
                range: range
            )
        case .keyboard:
            applyAndStore(
                .keyboard(shouldApplyMarkup),
                blockId: blockId,
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
        guard let content = blockContent(blockId: blockId) else { return }
        
        let restrictions = BlockRestrictionsFactory().makeTextRestrictions(
            for: content.contentType
        )
        guard restrictions.canApplyOtherMarkup else { return }
        
        applyAndStore(
            .link(link),
            blockId: blockId,
            content: content,
            attributedText: attributedText,
            range: range
        )
    }
}
