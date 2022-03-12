import Foundation
import SwiftUI

final class StatusSearchViewModel {
        
    @Published private var rows: [NewSearchRowConfiguration] = []
    
    private var statuses: [Relation.Status.Option] = [] {
        didSet {
            rows = statuses.asRowsConfigurations
        }
    }
    
    private let interactor: StatusSearchInteractor
    
    init(interactor: StatusSearchInteractor) {
        self.interactor = interactor
    }
    
}

extension StatusSearchViewModel: NewInternalSearchViewModelProtocol {
    
    var rowsPublisher: Published<[NewSearchRowConfiguration]>.Publisher { $rows }
    
    func search(text: String) {
        interactor.search(text: text) { [weak self] statuses in
            self?.statuses = statuses
        }
    }
    
    func handleRowSelect(rowId: String) {
        let index = rows.firstIndex { $0.id == rowId }
        
        guard let index = index else { return }

        debugPrint("selected index \(index)")
    }
    
}

private extension Array where Element == Relation.Status.Option {

    var asRowsConfigurations: [NewSearchRowConfiguration] {
        map { option in
            NewSearchRowConfiguration(
                id: option.id,
                rowContentHash: option.hashValue) {
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

