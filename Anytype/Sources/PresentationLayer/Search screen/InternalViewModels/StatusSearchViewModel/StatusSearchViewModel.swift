import Foundation
import SwiftUI
import Combine

final class StatusSearchViewModel {
    
    let selectionMode: NewSearchViewModel.SelectionMode
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    
    private var selectedStatusesIds: [String] = []
    private var statuses: [Relation.Status.Option] = []
    
    private let interactor: StatusSearchInteractor
    
    init(selectionMode: NewSearchViewModel.SelectionMode, interactor: StatusSearchInteractor) {
        self.selectionMode = selectionMode
        self.interactor = interactor
        self.setup()
    }
    
    private func setup() {
        if case let .multipleItems(preselectedIds) = selectionMode {
            self.selectedStatusesIds = preselectedIds
        }
    }
}

extension StatusSearchViewModel: NewInternalSearchViewModelProtocol {
    
    func search(text: String) {
        let result = interactor.search(text: text)
        switch result {
        case .success(let statuses):
            self.statuses = statuses
            
            handleSearchResults(statuses)
        case .failure(let error):
            handleError(for: error)
        }
    }
    
    func handleRowsSelection(ids: [String]) {
        guard statuses.isNotEmpty else { return }
        
        selectedStatusesIds = ids
        handleSearchResults(statuses)
    }
    
    func isCreateButtonAvailable(searchText: String) -> Bool {
        interactor.isCreateButtonAvailable(searchText: searchText)
    }
    
}

private extension StatusSearchViewModel {
    
    func handleError(for error: NewSearchError) {
        viewStateSubject.send(.error(error))
    }
    
    func handleSearchResults(_ statuses: [Relation.Status.Option]) {
        let sections = NewSearchSectionsBuilder.makeSections(statuses) {
            $0.asRowConfigurations(with: selectedStatusesIds, selectionMode: selectionMode)
        }
        viewStateSubject.send(.resultsList(.sectioned(sectinos: sections)))
    }
    
}

private extension Array where Element == Relation.Status.Option {

    func asRowConfigurations(with selectedIds: [String], selectionMode: NewSearchViewModel.SelectionMode) -> [ListRowConfiguration] {
        map { option in
            ListRowConfiguration(
                id: option.id,
                contentHash: option.hashValue
            ) {
                AnyView(
                    StatusSearchRowView(
                        viewModel: StatusSearchRowView.Model(
                            text: option.text,
                            color: option.color
                        ),
                        selectionIndicatorViewModel: selectionMode.asSelectionIndicatorViewModel(option: option, selectedIds: selectedIds)
                    )
                )
            }
        }
    }
}

private extension NewSearchViewModel.SelectionMode {
    
    func asSelectionIndicatorViewModel(option: Relation.Status.Option, selectedIds: [String]) -> SelectionIndicatorView.Model? {
        switch self {
        case .multipleItems:
            return SelectionIndicatorViewModelBuilder.buildModel(id: option.id, selectedIds: selectedIds)
        case .singleItem:
            return nil
        }
    }
}

