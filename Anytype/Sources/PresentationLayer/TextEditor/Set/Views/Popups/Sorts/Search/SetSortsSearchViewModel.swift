import Combine
import Services

final class SetSortsSearchViewModel {
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never> ()
    
    private let interactor: SetSortsSearchInteractor
    private let onSelect: (_ details: [RelationDetails]) -> Void
    
    init(interactor: SetSortsSearchInteractor, onSelect: @escaping (_ details: [RelationDetails]) -> Void) {
        self.interactor = interactor
        self.onSelect = onSelect
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
    
    func handleConfirmSelection(ids: [String]) {
        onSelect(interactor.convert(ids: ids))
    }
}

private extension SetSortsSearchViewModel {
    
    func handleError(_ error: NewSearchError) {
        viewStateSubject.send(.error(error))
    }
    
    func handleSearchResults(_ relationsDetails: [RelationDetails]) {
        viewStateSubject.send(.resultsList(.plain(rows: relationsDetails.asRowConfigurations())))
    }
    
}

private extension Array where Element == RelationDetails {

    func asRowConfigurations() -> [ListRowConfiguration] {
        map { relationDetails in
            ListRowConfiguration(
                id: relationDetails.id,
                contentHash: relationDetails.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(relationDetails: relationDetails),
                    selectionIndicatorViewModel: nil
                ).eraseToAnyView()
            }
        }
    }
    
}



