import Foundation
import SwiftUI
import Combine

@MainActor
final class StatusSearchViewModel {
    
    let selectionMode: LegacySearchViewModel.SelectionMode
    
    private let viewStateSubject = PassthroughSubject<LegacySearchViewState, Never>()
    private var selectedStatusesIds: [String] = []
    private var statuses: [Property.Status.Option] = []
    
    private let interactor: StatusSearchInteractor
    private let onSelect: (_ ids: [String]) -> Void
    
    init(
        selectionMode: LegacySearchViewModel.SelectionMode,
        interactor: StatusSearchInteractor,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) {
        self.selectionMode = selectionMode
        self.interactor = interactor
        self.onSelect = onSelect
        self.setup()
    }
    
    private func setup() {
        if case let .multipleItems(preselectedIds) = selectionMode {
            self.selectedStatusesIds = preselectedIds
        }
    }
}

extension StatusSearchViewModel: NewInternalSearchViewModelProtocol {
    
    var viewStatePublisher: AnyPublisher<LegacySearchViewState, Never> { viewStateSubject.eraseToAnyPublisher() }
    
    func search(text: String) async throws {
        statuses = try await interactor.search(text: text)
        handleSearchResults(statuses)
    }
    
    func handleRowsSelection(ids: [String]) {
        guard statuses.isNotEmpty else { return }
        
        selectedStatusesIds = ids
        handleSearchResults(statuses)
    }
    
    func handleConfirmSelection(ids: [String]) {
        onSelect(ids)
    }
    
    func createButtonModel(searchText: String) -> LegacySearchViewModel.CreateButtonModel {
        return interactor.isCreateButtonAvailable(searchText: searchText, statuses: statuses)
            ? .enabled(title:  Loc.createOptionWith(searchText))
            : .disabled
    }
    
}

private extension StatusSearchViewModel {
    
    func handleError(for error: LegacySearchError) {
        viewStateSubject.send(.error(error))
    }
    
    func handleSearchResults(_ statuses: [Property.Status.Option]) {
        let sections = LegacySearchSectionsBuilder.makeSections(statuses) {
            $0.asRowConfigurations(with: selectedStatusesIds, selectionMode: selectionMode)
        }
        viewStateSubject.send(.resultsList(.sectioned(sectinos: sections)))
    }
    
}

private extension Array where Element == Property.Status.Option {

    func asRowConfigurations(with selectedIds: [String], selectionMode: LegacySearchViewModel.SelectionMode) -> [ListRowConfiguration] {
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

private extension LegacySearchViewModel.SelectionMode {
    
    func asSelectionIndicatorViewModel(option: Property.Status.Option, selectedIds: [String]) -> SelectionIndicatorView.Model? {
        switch self {
        case .multipleItems:
            return SelectionIndicatorViewModelBuilder.buildModel(id: option.id, selectedIds: selectedIds)
        case .singleItem:
            return nil
        }
    }
}

