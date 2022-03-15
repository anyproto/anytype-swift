import Foundation
import SwiftUI
import Combine

final class StatusSearchViewModel {
    
    @Published private var sections: [NewSearchSectionConfiguration] = []
    
    private var statuses: [Relation.Status.Option] = [] {
        didSet {
            sections = NewSearchSectionsBuilder.makeSections(statuses) {
                $0.asRowsConfigurations
            }
        }
    }
    
    private let interactor: StatusSearchInteractor
    
    init(interactor: StatusSearchInteractor) {
        self.interactor = interactor
    }
    
}

extension StatusSearchViewModel: NewInternalSearchViewModelProtocol {
    
    var listModelPublisher: AnyPublisher<NewSearchView.ListModel, Never> {
        $sections.map { sections -> NewSearchView.ListModel in
            NewSearchView.ListModel.sectioned(sectinos: sections)
        }.eraseToAnyPublisher()
    }
    
    func search(text: String) {
        interactor.search(text: text) { [weak self] statuses in
            self?.statuses = statuses
        }
    }
    
    func handleRowsSelection(ids: [String]) {
       
    }
    
}

private extension Array where Element == Relation.Status.Option {

    var asRowsConfigurations: [NewSearchRowConfiguration] {
        map { option in
            NewSearchRowConfiguration(
                id: option.id,
                rowContentHash: option.hashValue
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
