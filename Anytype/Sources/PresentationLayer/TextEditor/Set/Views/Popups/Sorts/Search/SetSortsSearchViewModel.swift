import Combine
import BlocksModels

final class SetSortsSearchViewModel {
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never> ()
    
    private let interactor: SetSortsSearchInteractor
    
    init(interactor: SetSortsSearchInteractor) {
        self.interactor = interactor
    }
}

extension SetSortsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    func search(text: String) {
        let result = interactor.search(text: text)
        switch result {
        case .success(let relations):
            handleSearchResults(relations)
        case .failure(let error):
            handleError(error)
        }
    }
    
    func handleRowsSelection(ids: [String]) {}
}

private extension SetSortsSearchViewModel {
    
    func handleError(_ error: NewSearchError) {
        viewStateSubject.send(.error(error))
    }
    
    func handleSearchResults(_ relations: [RelationMetadata]) {
        viewStateSubject.send(.resultsList(.plain(rows: relations.asRowConfigurations())))
    }
    
}

private extension Array where Element == RelationMetadata {

    func asRowConfigurations() -> [ListRowConfiguration] {
        map { relation in
            ListRowConfiguration(
                id: relation.id,
                contentHash: relation.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(relation: relation),
                    selectionIndicatorViewModel: nil
                ).eraseToAnyView()
            }
        }
    }
    
}

private extension SearchObjectRowView.Model {
    
    init(relation: RelationMetadata) {
        self.icon = .imageAsset(relation.format.iconAsset)
        self.title = relation.name
        self.subtitle = nil
        self.style = .compact
        self.isChecked = false
    }
    
}

