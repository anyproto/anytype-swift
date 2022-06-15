import Foundation
import BlocksModels
import Combine
import SwiftUI

final class MultiselectObjectTypesSearchViewModel {
    
    let selectionMode: NewSearchViewModel.SelectionMode = .multipleItems
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    
    private var objects: [ObjectDetails] = []
    private var selectedObjectTypeIds: [String] = []
    
    private let interactor: ObjectTypesSearchInteractor
    
    init(selectedObjectTypeIds: [String], interactor: ObjectTypesSearchInteractor) {
        self.selectedObjectTypeIds = selectedObjectTypeIds
        self.interactor = interactor
    }
    
}

extension MultiselectObjectTypesSearchViewModel: NewInternalSearchViewModelProtocol {
    
    func search(text: String) {
        let objects = interactor.search(text: text)
        
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
    
}

private extension MultiselectObjectTypesSearchViewModel {
    
    func handleError(for text: String) {
        viewStateSubject.send(.error(.noObjectError(searchText: text)))
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
        let title = details.title
        self.icon = {
            if details.layout == .todo {
                return .todo(details.isDone)
            } else {
                return details.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
            }
        }()
        self.title = title
        self.subtitle = details.description
        self.style = .default
    }
    
}
