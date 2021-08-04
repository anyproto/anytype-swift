import AnytypeCore
import BlocksModels
import Foundation

final class MarkupViewModel {
    
    var blockInformation: BlockInformation? {
        didSet {
            guard case .text = blockInformation?.content else { return }
            displayCurrentState()
        }
    }
    weak var view: MarkupViewProtocol?
    private let actionHandler: EditorActionHandlerProtocol
    private var selectedRange: MarkupRange?
    
    init(actionHandler: EditorActionHandlerProtocol) {
        self.actionHandler = actionHandler
    }
    
    func setRange(_ range: MarkupRange) {
        selectedRange = range
        displayCurrentState()
    }
    
    func dismissView() {
        view?.dismiss()
    }
    
    private func displayCurrentState() {
        guard let blockInformation = blockInformation,
              case let .text(textContent) = blockInformation.content,
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
        content: BlockText,
        blockId: BlockId
    ) {
        guard let range = selectedRange?.range(for: content.attributedText) else { return }
        actionHandler.handleAction(
            .toggleFontStyle(markup, range),
            blockId: blockId
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
        guard let blockInformation = blockInformation else {
            anytypeAssertionFailure("blockInformation must not be nil")
            return
        }
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
                content: content,
                blockId: blockInformation.id
            )
        }
    }
    
    func viewLoaded() {
        displayCurrentState()
    }
}
