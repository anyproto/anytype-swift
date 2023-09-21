import Foundation
import Services
import Combine
import SwiftUI
import AnytypeCore

final class ObjectsSearchViewModel {
    
    let selectionMode: NewSearchViewModel.SelectionMode
    
    private let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    private let interactor: ObjectsSearchInteractorProtocol
    private let onSelect: (_ details: [ObjectDetails]) -> Void
    
    private var objects: [ObjectDetails] = []
    private var selectedObjectIds: [String] = []
    
    init(
        selectionMode: NewSearchViewModel.SelectionMode,
        interactor: ObjectsSearchInteractorProtocol,
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
    
    var viewStatePublisher: AnyPublisher<NewSearchViewState, Never> { viewStateSubject.eraseToAnyPublisher() }
    
    func search(text: String) async throws {
        let objects = try await interactor.search(text: text)
        
        if objects.isEmpty {
            handleError(for: text)
        } else {
            handleSearchResults(objects)
        }
        
        self.objects = objects
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

    func asRowConfigurations(with selectedIds: [String], selectionMode: NewSearchViewModel.SelectionMode) -> [ListRowConfiguration] {
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

private extension NewSearchViewModel.SelectionMode {
    
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
        let title = details.title
        self.icon = details.objectIconImage
        self.title = title
        self.subtitle = details.objectType.name
        self.style = .default
        self.isChecked = false
    }
    
}
