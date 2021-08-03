import AnytypeCore
import BlocksModels
import Foundation

final class TextAttributesViewModel {
    
    private let actionHandler: EditorActionHandlerProtocol
    private var blockInformation: BlockInformation
    private weak var view: TextAttributesViewProtocol?
    private var selectedRange: MarkupRange?
    
    init(
        actionHandler: EditorActionHandlerProtocol,
        blockInformation: BlockInformation
    ) {
        self.actionHandler = actionHandler
        self.blockInformation = blockInformation
    }
    
    func setView(_ view: TextAttributesViewProtocol) {
        self.view = view
        displayCurrentState()
    }
    
    func setRange(_ range: MarkupRange) {
        selectedRange = range
        displayCurrentState()
    }
    
    func setInformation(_ information: BlockInformation) {
        guard case .text = information.content else {
            anytypeAssertionFailure("Expected text content type but got: \(information.content)")
            return
        }
        blockInformation = information
        displayCurrentState()
    }
    
    func hideView() {
        view?.hideView()
    }
    
    private func displayCurrentState() {
        guard case let .text(textContent) = blockInformation.content else {
            return
        }
        displayAttributes(from: textContent, alignment: blockInformation.alignment)
    }
    
    private func handleAlignmentChange(alignment: LayoutAlignment) {
        actionHandler.handleAction(.setAlignment(alignment), blockId: blockInformation.id)
    }
    
    private func handleMarkupChange(
        markup: BlockHandlerActionType.TextAttributesType,
        content: BlockText
    ) {
        guard let range = selectedRange?.range(for: content.attributedText) else { return }
        actionHandler.handleAction(
            .toggleFontStyle(markup, range),
            blockId: blockInformation.id
        )
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

extension TextAttributesViewModel: TextAttributesViewModelProtocol {
    
    func handle(action: TextAttributesViewModelAction) {
        guard case let .text(content) = blockInformation.content else {
            return
        }
        switch action {
        case let .selectAlignment(alignment):
            handleAlignmentChange(alignment: alignment)
        case let .toggleMarkup(markup):
            handleMarkupChange(
                markup: markup,
                content: content
            )
        }
    }
}
