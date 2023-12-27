import AnytypeCore
import Services
import Foundation

final class BlockMarkupChanger: BlockMarkupChangerProtocol {
    
    private let document: BaseDocumentProtocol
    
    init(document: BaseDocumentProtocol) {
        self.document = document
    }
    
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId)  -> NSAttributedString? {
        guard let info = document.infoContainer.get(id: blockId) else { return nil }
        guard case let .text(blockText) = info.content else { return nil }
        
        let range = blockText.anytypeText(document: document).attrString.wholeRange
        
        return toggleMarkup(markup, blockId: blockId, range: range)
    }
    
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        guard let content = blockData(blockId: blockId) else { return nil }

        let restrictions = BlockRestrictionsBuilder.build(textContentType: content.contentType)

        guard restrictions.isMarkupAvailable(markup) else { return nil }

        let attributedText = content.anytypeText(document: document).attrString
        let shouldApplyMarkup = !attributedText.hasMarkup(markup, range: range)

        return apply(
            markup,
            shouldApplyMarkup: shouldApplyMarkup,
            content: content,
            attributedText: attributedText,
            range: range
        )
    }

    func setMarkup(
        _ markup: MarkupType, blockId: BlockId, range: NSRange, currentText: NSAttributedString?
    ) -> NSAttributedString? {
        return updateMarkup(markup, shouldApplyMarkup: true, blockId: blockId, range: range, currentText: currentText)
    }

    func removeMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        return updateMarkup(markup, shouldApplyMarkup: false, blockId: blockId, range: range)
    }

    private func updateMarkup(
        _ markup: MarkupType, shouldApplyMarkup: Bool, blockId: BlockId, range: NSRange, currentText: NSAttributedString? = nil
    ) -> NSAttributedString? {
        guard let content = blockData(blockId: blockId) else { return nil }

        let restrictions = BlockRestrictionsBuilder.build(textContentType: content.contentType)

        guard restrictions.isMarkupAvailable(markup) else { return nil }

        let attributedText = currentText ?? content.anytypeText(document: document).attrString

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

        switch action {
        case .link(let linkURL):
            if linkURL.isNotNil {
                modifier.apply(.linkToObject(nil), shouldApplyMarkup: true, range: range)
            }
        case .linkToObject(let blockId):
            if blockId.isNotNil {
                modifier.apply(.link(nil), shouldApplyMarkup: true, range: range)
            }
        default: break
        }

        return NSAttributedString(attributedString: modifier.attributedString)
    }
    
    private func blockData(blockId: BlockId) -> BlockText? {
        guard let info = document.infoContainer.get(id: blockId) else {
            anytypeAssertionFailure("Can't find block", info: ["blockId": blockId])
            return nil
        }
        guard case let .text(content) = info.content else {
            anytypeAssertionFailure("Unexpected block type", info: ["type": "\(info.content.type)"])
            return nil
        }
        return content
    }
}
