import Foundation
import Combine
import SwiftUI

final class TagsSearchViewModel {
    
    @Published private var sections: [NewSearchSectionConfiguration] = []
    
    private var tags: [Relation.Tag.Option] = [] {
        didSet {
            sections = NewSearchSectionsBuilder.makeSections(tags) {
                $0.asRowsConfigurations
            }
        }
    }
    
    private let interactor: TagsSearchInteractor
    
    init(interactor: TagsSearchInteractor) {
        self.interactor = interactor
    }
    
}

extension TagsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    var listModelPublisher: AnyPublisher<NewSearchView.ListModel, Never> {
        $sections.map { sections -> NewSearchView.ListModel in
            NewSearchView.ListModel.sectioned(sectinos: sections)
        }.eraseToAnyPublisher()
    }
    
    func search(text: String) {
        interactor.search(text: text) { [weak self] tags in
            self?.tags = tags
        }
    }
    
    func handleRowSelect(rowId: String) {
        let index = tags.firstIndex { $0.id == rowId }
        
        guard let index = index else { return }

        debugPrint("selected index \(index)")
    }
    
}

private extension Array where Element == Relation.Tag.Option {

    var asRowsConfigurations: [NewSearchRowConfiguration] {
        map { option in
            NewSearchRowConfiguration(
                id: option.id,
                rowContentHash: option.hashValue
            ) {
                AnyView(
                    TagSearchRowView(
                        viewModel: TagView.Model(
                            text: option.text,
                            textColor: option.textColor,
                            backgroundColor: option.backgroundColor
                        ),
                        guidlines: RelationStyle.regular(allowMultiLine: false).tagViewGuidlines,
                        selectionIndicatorViewModel: .notSelected
                    )
                )
            }
        }
    }
}
