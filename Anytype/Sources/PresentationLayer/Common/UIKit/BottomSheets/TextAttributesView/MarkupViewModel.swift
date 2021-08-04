import AnytypeCore
import BlocksModels
import Foundation

final class MarkupViewModel {
    
    private let actionHandler: EditorActionHandlerProtocol
    private var blockInformation: BlockInformation
    private var selectedRange: MarkupRange?
    weak var view: MarkupViewProtocol?
    
    init(
        actionHandler: EditorActionHandlerProtocol,
        blockInformation: BlockInformation
    ) {
        self.actionHandler = actionHandler
        self.blockInformation = blockInformation
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
        view?.dismiss()
    }
    
    private func displayCurrentState() {
        guard case let .text(textContent) = blockInformation.content,
              let range = selectedRange else {
            return
        }
        let displayState = textAttributes(
            from: textContent,
            range: range.range(for: textContent.attributedText),
            alignment: blockInformation.alignment
        )
        view?.setMarkupState(displayState)
    }
    
    private func setMarkup(
        markup: BlockHandlerActionType.TextAttributesType,
        content: BlockText
    ) {
        guard let range = selectedRange?.range(for: content.attributedText) else { return }
        actionHandler.handleAction(
            .toggleFontStyle(markup, range),
            blockId: blockInformation.id
        )
    }
    
    private func textAttributes(
        from content: BlockText,
        range: NSRange,
        alignment: LayoutAlignment
    ) -> AllMarkupsState {
        let restrictions = BlockRestrictionsFactory().makeTextRestrictions(for: content.contentType)
        let markupCalculator = MarkupStateCalculator(
            attributedText: content.attributedText,
            range: range,
            restrictions: restrictions
        )
        return AllMarkupsState(
            bold: markupCalculator.boldState(),
            italic: markupCalculator.italicState(),
            strikethrough: markupCalculator.strikethroughState(),
            codeStyle: markupCalculator.codeState(),
            alignment: alignment.asNSTextAlignment,
            url: nil
        )
    }
}

extension MarkupViewModel: MarkupViewModelProtocol {
    
    func handle(action: MarkupViewModelAction) {
        guard case let .text(content) = blockInformation.content else {
            anytypeAssertionFailure("Expected text content type but got: \(blockInformation.content)")
            return
        }
        switch action {
        case let .selectAlignment(alignment):
            actionHandler.handleAction(
                .setAlignment(alignment),
                blockId: blockInformation.id
            )
        case let .toggleMarkup(markup):
            setMarkup(
                markup: markup,
                content: content
            )
        }
    }
    
    func viewLoaded() {
        displayCurrentState()
    }
}
