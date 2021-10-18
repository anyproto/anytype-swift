import AnytypeCore
import BlocksModels

final class BlockMarkupChanger: BlockMarkupChangerProtocol {
    
    weak var handler: EditorActionHandlerProtocol?
    
    private let document: BaseDocumentProtocol
    private let documentId: String

    init(
        document: BaseDocumentProtocol,
        documentId: String
    ) {
        self.document = document
        self.documentId = documentId
    }
    
    func toggleMarkup(
        _ markup: BlockHandlerActionType.TextAttributesType,
        for blockId: BlockId
    ) {
        guard let info = document.rootModel?.blocksContainer.model(id: blockId)?.information,
              case let .text(blockText) = info.content else { return }
        
        toggleMarkup(
            markup,
            attributedText: blockText.anytypeText.attrString,
            for: blockId,
            in: blockText.anytypeText.attrString.wholeRange
        )
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
        applyAndStore(
            markup.marksStyleAction(shouldApplyMarkup: shouldApplyMarkup),
            block: model,
            content: content,
            attributedText: attributedText,
            range: range
        )
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
    
    private func applyAndStore(
        _ action: MarkStyleAction,
        block: BlockModelProtocol,
        content: BlockText,
        attributedText: NSAttributedString,
        range: NSRange
    ) {
        // Ignore changing markup in empty string 
        guard range.length != 0 else { return }
        
        let modifier = MarkStyleModifier(
            attributedString: attributedText,
            anytypeFont: content.contentType.uiFont
        )
        
        modifier.apply(action, range: range)
        let result = NSAttributedString(attributedString: modifier.attributedString)
        
        handler?.handleAction(
            .textView(action: .changeText(result), block: block),
            blockId: block.information.id
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
}
