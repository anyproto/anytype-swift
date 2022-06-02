import Foundation
import SwiftUI
import Combine

final class StatusSearchViewModel {
    
    let selectionMode: NewSearchViewModel.SelectionMode = .singleItem
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()
    
    private var statuses: [Relation.Status.Option] = []
    
    private let interactor: StatusSearchInteractor
    
    init(interactor: StatusSearchInteractor) {
        self.interactor = interactor
    }
    
}

extension StatusSearchViewModel: NewInternalSearchViewModelProtocol {
    
    func search(text: String) {
        let result = interactor.search(text: text)
        switch result {
        case .success(let statuses):
            self.statuses = statuses
            
            let sections = NewSearchSectionsBuilder.makeSections(statuses) {
                $0.asRowsConfigurations
            }
            viewStateSubject.send(.resultsList(.sectioned(sectinos: sections)))
            
        case .failure(let error):
            viewStateSubject.send(.error(error))
        }
    }
    
    func handleRowsSelection(ids: [String]) {}
    
    func isCreateButtonAvailable(searchText: String) -> Bool {
        interactor.isCreateButtonAvailable(searchText: searchText)
    }
    
}

private extension Array where Element == Relation.Status.Option {

    var asRowsConfigurations: [ListRowConfiguration] {
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
                        )
                    )
                )
            }
        }
    }
}
