import Foundation
import Services
import Combine
import SwiftUI
import AnytypeCore

final class MultiselectObjectTypesSearchViewModel {
    
    let selectionMode: LegacySearchViewModel.SelectionMode = .multipleItems()
    
    private let viewStateSubject = PassthroughSubject<LegacySearchViewState, Never>()
    private var objects: [ObjectDetails] = []
    private var selectedObjectTypeIds: [String] = []
    
    private let interactor: Legacy_ObjectTypeSearchInteractor
    private let onSelect: (_ ids: [String]) -> Void
    
    init(
        selectedObjectTypeIds: [String],
        interactor: Legacy_ObjectTypeSearchInteractor,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) {
        self.selectedObjectTypeIds = selectedObjectTypeIds
        self.interactor = interactor
        self.onSelect = onSelect
    }
    
}

extension MultiselectObjectTypesSearchViewModel: NewInternalSearchViewModelProtocol {
    
    var viewStatePublisher: AnyPublisher<LegacySearchViewState, Never> { viewStateSubject.eraseToAnyPublisher() }
    
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
        
        self.selectedObjectTypeIds = ids
        handleSearchResults(objects)
    }
    
    func handleConfirmSelection(ids: [String]) {
        onSelect(ids)
    }
}

private extension MultiselectObjectTypesSearchViewModel {
    
    func handleError(for text: String) {
        viewStateSubject.send(.error(.noTypeError(searchText: text)))
    }
    
    func handleSearchResults(_ objects: [ObjectDetails]) {
        viewStateSubject.send(
            .resultsList(
                .plain(rows: objects.asRowConfigurations(with: selectedObjectTypeIds))
            )
        )
    }
}

private extension Array where Element == ObjectDetails {

    func asRowConfigurations(with selectedIds: [String]) -> [ListRowConfiguration] {
        map { details in
            ListRowConfiguration(
                id: details.id,
                contentHash: details.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(details: details),
                    selectionIndicatorViewModel: SelectionIndicatorViewModelBuilder.buildModel(id: details.id, selectedIds: selectedIds)
                ).eraseToAnyView()
            }
        }
    }
    
}

private extension SearchObjectRowView.Model {
    
    init(details: ObjectDetails) {
        let title = details.pluralTitle
        self.id = details.id
        self.icon = details.objectIconImage
        self.title = title
        self.subtitle = details.description
        self.style = .default
        self.isChecked = false
    }
    
}
