import AnytypeCore
import BlocksModels
import Foundation

final class TextAttributesViewModel {
    
    private let actionHandler: EditorActionHandlerProtocol
    private let container: RootBlockContainer
    private let blockId: BlockId
    private var blockEventsListener: TextBlockContentChangeListener?
    private weak var view: TextAttributesViewProtocol?
    private var selectedRange: MarkupRange?
    
    init(
        actionHandler: EditorActionHandlerProtocol,
        container: RootBlockContainer,
        blockId: BlockId
    ) {
        self.actionHandler = actionHandler
        self.container = container
        self.blockId = blockId
    }
    
    func setView(_ view: TextAttributesViewProtocol) {
        self.view = view
    }
    
    func setEventsListener(_ listener: TextBlockContentChangeListener) {
        blockEventsListener = listener
    }
    
    func setRange(_ range: MarkupRange) {
        selectedRange = range
        guard let information = container.blocksContainer.model(id: blockId)?.information else {
            anytypeAssertionFailure("Unable to get block model by id: \(blockId)")
            return
        }
        guard case let .text(textContent) = information.content else {
            anytypeAssertionFailure("Expected text content type but got: \(information.content)")
            return
        }
        displayAttributes(from: textContent, alignment: information.alignment)
    }
    
    func handle(action: TextAttributesViewModelAction) {
        guard let information = container.blocksContainer.model(id: blockId)?.information,
              case let .text(content) = information.content else {
            return
        }
        switch action {
        case let .selectAlignment(alignment):
            handleAlignmentChange(
                alignment: alignment,
                content: content
            )
        case let .toggleMarkup(markup):
            handleMarkupChange(
                markup: markup,
                content: content,
                alignment: information.alignment
            )
        }
    }
    
    private func handleAlignmentChange(
        alignment: LayoutAlignment,
        content: BlockText
    ) {
        actionHandler.handleAction(
            .setAlignment(alignment),
            blockId: blockId
        )
        displayAttributes(
            from: content,
            alignment: alignment
        )
    }
    
    private func handleMarkupChange(
        markup: BlockHandlerActionType.TextAttributesType,
        content: BlockText,
        alignment: LayoutAlignment
    ) {
        guard let range = selectedRange?.range(for: content.attributedText) else { return }
        actionHandler.handleAction(
            .toggleFontStyle(markup, range),
            blockId: blockId
        )
        var displayState = textAttributes(
            from: content,
            range: range,
            alignment: alignment
        )
        switch markup {
        case .bold:
            displayState.bold.toggleAppliedState()
        case .italic:
            displayState.italic.toggleAppliedState()
        case .keyboard:
            displayState.codeStyle.toggleAppliedState()
        case .strikethrough:
            displayState.strikethrough.toggleAppliedState()
        }
        view?.display(displayState)
    }
    
    private func displayAttributes(
        from content: BlockText,
        alignment: LayoutAlignment
    ) {
        guard let range = selectedRange else { return }
        let displayState = textAttributes(from: content,
                                          range: range.range(for: content.attributedText),
                                          alignment: alignment)
        view?.display(displayState)
    }
    
    private func textAttributes(
        from content: BlockText,
        range: NSRange,
        alignment: LayoutAlignment
    ) -> TextAttributesState {
        let restrictions = BlockRestrictionsFactory().makeTextRestrictions(for: content.contentType)
        let markupCalculator = MarkupStateCalculator(
            attributedText: content.attributedText,
            range: range,
            restrictions: restrictions
        )
        return TextAttributesState(
            bold: markupCalculator.boldState(),
            italic: markupCalculator.italicState(),
            strikethrough: markupCalculator.strikethroughState(),
            codeStyle: markupCalculator.codeState(),
            alignment: alignment.asNSTextAlignment,
            url: ""
        )
    }
}

extension TextAttributesViewModel: TextBlockContentChangeListenerDelegate {
    
    func blockInformationDidChange(_ information: BlockInformation) {
        guard case let .text(textContent) = information.content else {
            view?.hideView()
            return
        }
        displayAttributes(
            from: textContent,
            alignment: information.alignment
        )
    }
}
