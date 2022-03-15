import Foundation
import BlocksModels
import Combine
import SwiftUI

final class ObjectsSearchViewModel {
    
    @Published private var rows: [NewSearchRowConfiguration] = []
    
    private var objects: [ObjectDetails] = [] {
        didSet {
            rows = objects.asRowConfigurations(with: selectedObjectIds)
        }
    }
    
    private var selectedObjectIds: [String] = [] {
        didSet {
            rows = objects.asRowConfigurations(with: selectedObjectIds)
        }
    }
    
    private let interactor: ObjectsSearchInteractorProtocol
    
    init(interactor: ObjectsSearchInteractorProtocol) {
        self.interactor = interactor
    }
    
}

extension ObjectsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    var listModelPublisher: AnyPublisher<NewSearchView.ListModel, Never> {
        $rows.map { rows -> NewSearchView.ListModel in
            NewSearchView.ListModel.plain(rows: rows)
        }.eraseToAnyPublisher()
    }
    
    func search(text: String) {
        interactor.search(text: text) { [weak self] objects in
            self?.objects = objects
        }
    }
    
    func handleRowsSelection(ids: [String]) {
        self.selectedObjectIds = ids
    }
    
}

private extension Array where Element == ObjectDetails {

    func asRowConfigurations(with selectedIds: [String]) -> [NewSearchRowConfiguration] {
        map { details in
            NewSearchRowConfiguration(
                id: details.id,
                rowContentHash: details.hashValue
            ) {
                AnyView(
                    SearchObjectRowView(
                        viewModel: SearchObjectRowView.Model(details: details),
                        selectionIndicatorViewModel: SelectionIndicatorViewModelBuilder.buildModel(id: details.id, selectedIds: selectedIds)
                    )
                )
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
        self.subtitle = details.objectType.name
    }
    
}

