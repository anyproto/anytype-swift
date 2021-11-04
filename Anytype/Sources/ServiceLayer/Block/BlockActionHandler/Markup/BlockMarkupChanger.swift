import AnytypeCore
import BlocksModels

final class BlockMarkupChanger: BlockMarkupChangerProtocol {
    
    weak var handler: EditorActionHandlerProtocol?
    
    private let blocksContainer: BlockContainerModelProtocol
    private let detailsStorage: ObjectDetailsStorageProtocol
    
    init(
        blocksContainer: BlockContainerModelProtocol,
        detailsStorage: ObjectDetailsStorageProtocol
    ) {
        self.blocksContainer = blocksContainer
        self.detailsStorage = detailsStorage
    }
    
    func toggleMarkup(
        _ markup: BlockHandlerActionType.TextAttributesType,
        for blockId: BlockId
    ) {
        guard let info = blocksContainer.model(id: blockId)?.information,
              case let .text(blockText) = info.content else { return }
        
        toggleMarkup(
            markup,
            attributedText: blockText.anytypeText(using: detailsStorage).attrString,
            for: blockId,
            in: blockText.anytypeText(using: detailsStorage).attrString.wholeRange
        )
    }
    
    func toggleMarkup(
        _ markup: BlockHandlerActionType.TextAttributesType,
        attributedText: NSAttributedString,
        for blockId: BlockId,
        in range: NSRange
    ) {
        guard let (model, content) = blockData(blockId: blockId) else { return }
        
        let restrictions = RestrictionsFactory.build(textContentType: content.contentType)
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
        
        let restrictions = RestrictionsFactory.build(textContentType: content.contentType)
        guard restrictions.canApplyOtherMarkup else { return }
        
        applyAndStore(
            .link(link),
            block: model,
            content: content,
            attributedText: attributedText,
            range: range
        )
    }

    func setLinkToObject(id: BlockId, attributedText: NSAttributedString, for blockId: BlockId, in range: NSRange) {
        guard let (model, content) = blockData(blockId: blockId) else { return }

        let restrictions = RestrictionsFactory.build(textContentType: content.contentType)

        guard restrictions.canApplyOtherMarkup else { return }

        applyAndStore(
            .linkToObject(id),
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
        
        handler?.changeText(result, info: block.information)
    }
    
    private func blockData(blockId: BlockId) -> (BlockModelProtocol, BlockText)? {
        guard let model = blocksContainer.model(id: blockId) else {
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
