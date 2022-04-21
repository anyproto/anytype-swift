import AnytypeCore
import BlocksModels
import Foundation

extension MarkupViewModel {
    struct AllAttributesState {
        let markup: [MarkupType: AttributeState]
        let alignment: [LayoutAlignment: AttributeState]
    }
}

final class MarkupViewModel {
    
    var blockInformation: BlockInformation? {
        didSet {
            guard case let .text(textBlock) = blockInformation?.content else { return }
            anytypeText = AttributedTextConverter.asModel(
                text: textBlock.text,
                marks: textBlock.marks,
                style: textBlock.contentType
            )
            displayCurrentState()
        }
    }
    weak var view: MarkupViewProtocol?
    private let actionHandler: BlockActionHandlerProtocol

    private var selectedRange: MarkupRange?
    private var anytypeText: UIKitAnytypeText?
    
    init(actionHandler: BlockActionHandlerProtocol) {
        self.actionHandler = actionHandler
    }
    
    func setRange(_ range: MarkupRange) {
        selectedRange = range
        displayCurrentState()
    }
    
    func removeInformationAndDismiss() {
        blockInformation = nil
        view?.dismiss()
    }
    
    private func displayCurrentState() {
        guard let blockInformation = blockInformation,
              case let .text(textContent) = blockInformation.content,
              let range = selectedRange,
              let anytypeText = anytypeText else {
            return
        }
        let displayState = textAttributes(
            anytypeText: anytypeText,
            from: textContent,
            range: range.range(for: anytypeText.attrString),
            alignment: blockInformation.alignment
        )
        view?.setMarkupState(displayState)
    }
    
    private func setMarkup(
        markup: MarkupType, blockId: BlockId
    ) {
        actionHandler.toggleWholeBlockMarkup(markup, blockId: blockId)
    }
    
    private func textAttributes(
        anytypeText: UIKitAnytypeText,
        from content: BlockText,
        range: NSRange,
        alignment: LayoutAlignment
    ) -> AllAttributesState {
        let restrictions = BlockRestrictionsBuilder.build(textContentType: content.contentType)

        let markupsStates = AttributeState.allMarkupAttributesState(in: range, string: anytypeText.attrString, with: restrictions)

        var alignmentsStates = [LayoutAlignment: AttributeState]()
        LayoutAlignment.allCases.forEach {
            guard restrictions.isAlignmentAvailable($0) else {
                alignmentsStates[$0] = .disabled
                return
            }
            alignmentsStates[$0] = alignment == $0 ? .applied : .notApplied
        }

        return .init(markup: markupsStates, alignment: alignmentsStates)
    }
}

extension MarkupViewModel: MarkupViewModelProtocol {
    
    func handle(action: MarkupViewModelAction) {
        guard let blockInformation = blockInformation else {
            anytypeAssertionFailure("blockInformation must not be nil", domain: .markupViewModel)
            return
        }
        guard case .text = blockInformation.content else {
            anytypeAssertionFailure(
                "Expected text content type but got: \(blockInformation.content)",
                domain: .markupViewModel
            )
            return
        }
        switch action {
        case let .selectAlignment(alignment):
            actionHandler.setAlignment(alignment, blockId: blockInformation.id.value)
        case let .toggleMarkup(markup):
            setMarkup(markup: markup, blockId: blockInformation.id.value)
        }
    }
    
    func viewLoaded() {
        displayCurrentState()
    }
}
