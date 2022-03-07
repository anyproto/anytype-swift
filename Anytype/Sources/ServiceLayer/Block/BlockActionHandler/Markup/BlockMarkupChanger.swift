import AnytypeCore
import BlocksModels

final class BlockMarkupChanger: BlockMarkupChangerProtocol {
    
    private let infoContainer: InfoContainerProtocol
    
    init(infoContainer: InfoContainerProtocol) {
        self.infoContainer = infoContainer
    }
    
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId)  -> NSAttributedString? {
        guard let info = infoContainer.get(id: blockId) else { return nil }
        guard case let .text(blockText) = info.content else { return nil }
        
        let range = blockText.anytypeText.attrString.wholeRange
        
        return toggleMarkup(markup, blockId: blockId, range: range)
    }
    
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        guard let content = blockData(blockId: blockId) else { return nil }

        let restrictions = BlockRestrictionsBuilder.build(textContentType: content.contentType)

        guard restrictions.isMarkupAvailable(markup) else { return nil }

        let attributedText = content.anytypeText.attrString
        let shouldApplyMarkup = !attributedText.hasMarkup(markup, range: range)

        return apply(
            markup,
            shouldApplyMarkup: shouldApplyMarkup,
            content: content,
            attributedText: attributedText,
            range: range
        )
    }

    func setMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        return updateMarkup(markup, shouldApplyMarkup: true, blockId: blockId, range: range)
    }

    func removeMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        return updateMarkup(markup, shouldApplyMarkup: false, blockId: blockId, range: range)
    }

    private func updateMarkup(
        _ markup: MarkupType, shouldApplyMarkup: Bool, blockId: BlockId, range: NSRange
    ) -> NSAttributedString? {
        guard let content = blockData(blockId: blockId) else { return nil }

        let restrictions = BlockRestrictionsBuilder.build(textContentType: content.contentType)

        guard restrictions.isMarkupAvailable(markup) else { return nil }

        let attributedText = content.anytypeText.attrString

        return apply(
            markup,
            shouldApplyMarkup: shouldApplyMarkup,
            content: content,
            attributedText: attributedText,
            range: range
        )
    }

    
    private func apply(
        _ action: MarkupType,
        shouldApplyMarkup: Bool,
        content: BlockText,
        attributedText: NSAttributedString,
        range: NSRange
    ) -> NSAttributedString? {
        // Ignore changing markup in empty string
        guard range.length != 0 else { return nil }
        
        let modifier = MarkStyleModifier(
            attributedString: attributedText,
            anytypeFont: content.contentType.uiFont
        )
        
        modifier.apply(action, shouldApplyMarkup: shouldApplyMarkup, range: range)
        return NSAttributedString(attributedString: modifier.attributedString)
    }
    
    private func blockData(blockId: BlockId) -> BlockText? {
        guard let info = infoContainer.get(id: blockId) else {
            anytypeAssertionFailure("Can't find block with id: \(blockId)", domain: .blockMarkupChanger)
            return nil
        }
        guard case let .text(content) = info.content else {
            anytypeAssertionFailure("Unexpected block type \(info.content)", domain: .blockMarkupChanger)
            return nil
        }
        return content
    }
}
