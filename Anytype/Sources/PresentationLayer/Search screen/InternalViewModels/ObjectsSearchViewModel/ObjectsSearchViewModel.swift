import Foundation
import Services
import Combine
import SwiftUI
import AnytypeCore

final class ObjectsSearchViewModel {
    
    let selectionMode: LegacySearchViewModel.SelectionMode
    
    private let viewStateSubject = PassthroughSubject<LegacySearchViewState, Never>()
    private let interactor: any ObjectsSearchInteractorProtocol
    let onSelect: (_ details: [ObjectDetails]) -> Void
    
    private var objects: [ObjectDetails] = []
    private var selectedObjectIds: [String] = []
    
    init(
        selectionMode: LegacySearchViewModel.SelectionMode,
        interactor: some ObjectsSearchInteractorProtocol,
        onSelect: @escaping (_ details: [ObjectDetails]) -> Void
    ) {
        self.selectionMode = selectionMode
        self.interactor = interactor
        self.onSelect = onSelect
        self.setup()
    }
    
    private func setup() {
        if case let .multipleItems(preselectedIds) = selectionMode {
            self.selectedObjectIds = preselectedIds
        }
    }
}

extension ObjectsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    var viewStatePublisher: AnyPublisher<LegacySearchViewState, Never> { viewStateSubject.eraseToAnyPublisher() }
    
    func search(text: String) async throws {
        let objects = try await interactor.search(text: text)
        
        if objects.isEmpty && text.isEmpty {
            handleError(for: text)
        } else {
            handleSearchResults(objects)
        }
        
        self.objects = objects
    }
    
    func createButtonModel(searchText: String) -> LegacySearchViewModel.CreateButtonModel {
        return searchText.isEmpty ? .disabled : .enabled(title: Loc.createObject + " \(searchText)")
    }
    
    func handleRowsSelection(ids: [String]) {
        guard objects.isNotEmpty else { return }
        
        self.selectedObjectIds = ids
        handleSearchResults(objects)
    }
    
    func handleConfirmSelection(ids: [String]) {
        let result = objects.filter { ids.contains($0.id) }
        onSelect(result)
    }
}

private extension ObjectsSearchViewModel {
    
    func handleError(for text: String) {
        viewStateSubject.send(.error(.noObjectError(searchText: text)))
    }
    
    func handleSearchResults(_ objects: [ObjectDetails]) {
        viewStateSubject.send(
            .resultsList(
                .plain(
                    rows: objects.asRowConfigurations(with: selectedObjectIds, selectionMode: selectionMode)
                )
            )
        )
    }
    
}

private extension Array where Element == ObjectDetails {

    func asRowConfigurations(with selectedIds: [String], selectionMode: LegacySearchViewModel.SelectionMode) -> [ListRowConfiguration] {
        map { details in
            ListRowConfiguration(
                id: details.id,
                contentHash: details.hashValue
            ) {
                AnyView(
                    SearchObjectRowView(
                        viewModel: SearchObjectRowView.Model(details: details),
                        selectionIndicatorViewModel: selectionMode.asSelectionIndicatorViewModel(
                            details: details,
                            selectedIds: selectedIds
                        )
                    )
                )
            }
        }
    }
}

private extension LegacySearchViewModel.SelectionMode {
    
    func asSelectionIndicatorViewModel(details: ObjectDetails, selectedIds: [String]) -> SelectionIndicatorView.Model? {
        switch self {
        case .multipleItems:
            return SelectionIndicatorViewModelBuilder.buildModel(id: details.id, selectedIds: selectedIds)
        case .singleItem:
            return nil
        }
    }
}

private extension SearchObjectRowView.Model {
    
    init(details: ObjectDetails) {
        let title = details.pluralTitle
        self.id = details.id
        self.icon = details.objectIconImage
        self.title = title
        self.subtitle = details.objectType.displayName
        self.style = .default
        self.isChecked = false
    }
    
}
