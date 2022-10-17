import AnytypeCore
import BlocksModels
import Foundation
import Combine

final class MarkupViewModel: MarkupViewModelProtocol {
    weak var view: MarkupViewProtocol?

    private let viewModelAdapter: MarkupViewModelAdapterProtocol
    private var cancellable: AnyCancellable? = nil
    
    init(viewModelAdadpter: MarkupViewModelAdapterProtocol) {
        self.viewModelAdapter = viewModelAdadpter
    }

    private func subscribeToPublishers() {
        cancellable = Publishers.Zip(
            viewModelAdapter.selectedMarkupsPublisher,
            viewModelAdapter.selectedHorizontalAlignmentPublisher
        ).sink { [weak self] markups, aligment in
            self?.displayCurrentState(selectedMarkups: markups, selectedHorizontalAlignment: aligment)
        }
    }

    private func displayCurrentState(
        selectedMarkups: [MarkupType: AttributeState],
        selectedHorizontalAlignment: [LayoutAlignment: AttributeState]
    ) {
        let displayMarkups: [MarkupViewType: AttributeState] = selectedMarkups.reduce(into: [:])
        { partialResult, item in
            if let key = item.key.markupViewType {
                partialResult[key] = item.value
            }
        }
        
        let displayHorizontalAlignment = selectedHorizontalAlignment.reduce(into: [:]) { partialResult, item in
            partialResult[item.key.layoutAlignmentViewType] = item.value
        }
        
        let displayState = MarkupViewsState(
            markup: displayMarkups,
            alignment: displayHorizontalAlignment
        )
        
        view?.setMarkupState(displayState)
    }

    // MARK: - MarkupViewModelProtocol
    
    func handle(action: MarupViewAction) {


        switch action {
        case .toggleMarkup(let markupType):
            viewModelAdapter.onMarkupAction(.toggleMarkup(markupType.markupType))
//            selectedMarkups[markupType] = selectedMarkups[markupType] == .applied ? .notApplied : .applied
        case .selectAlignment(let layoutAlignment):
            viewModelAdapter.onMarkupAction(.selectAlignment(layoutAlignment.layoutAlignment))
//            for (key, value) in selectedHorizontalAlignment {
//                if value == .disabled { continue }
//
//                selectedHorizontalAlignment[key] = .notApplied
//            }
//
//            selectedHorizontalAlignment[layoutAlignment] = .applied
        }

//        displayCurrentState()
    }

    func viewLoaded() {
        subscribeToPublishers()
//        displayCurrentState()
    }
}
