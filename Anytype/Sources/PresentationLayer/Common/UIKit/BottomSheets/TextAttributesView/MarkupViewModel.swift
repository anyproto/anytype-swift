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
    weak var view: MarkupViewProtocol?

    private var selectedMarkups: [MarkupType: AttributeState]
    private var selectedHorizontalAlignment: [LayoutAlignment: AttributeState]
    private let onMarkupAction: (MarkupViewModelAction) -> Void

    init(
        selectedMarkups: [MarkupType: AttributeState],
        selectedHorizontalAlignment: [LayoutAlignment: AttributeState],
        onMarkupAction: @escaping (MarkupViewModelAction) -> Void
    ) {
        self.selectedMarkups = selectedMarkups
        self.selectedHorizontalAlignment = selectedHorizontalAlignment
        self.onMarkupAction = onMarkupAction
    }
    

    private func displayCurrentState() {
        let displayState = AllAttributesState(
            markup: selectedMarkups,
            alignment: selectedHorizontalAlignment
        )

        view?.setMarkupState(displayState)
    }
}

// MARK: - MarkupViewModelProtocol
extension MarkupViewModel: MarkupViewModelProtocol {
    func handle(action: MarkupViewModelAction) {
        onMarkupAction(action)

        switch action {
        case .toggleMarkup(let markupType):
            selectedMarkups[markupType] = selectedMarkups[markupType] == .applied ? .notApplied : .applied
        case .selectAlignment(let layoutAlignment):
            for (key, value) in selectedHorizontalAlignment {
                if value == .disabled { continue }

                selectedHorizontalAlignment[key] = .notApplied
            }

            selectedHorizontalAlignment[layoutAlignment] = .applied
        }

        displayCurrentState()
    }

    func viewLoaded() {
        displayCurrentState()
    }
}
