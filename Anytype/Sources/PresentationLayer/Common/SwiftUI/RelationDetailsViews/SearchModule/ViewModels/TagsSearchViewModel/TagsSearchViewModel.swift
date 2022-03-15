import Foundation
import Combine
import SwiftUI

final class TagsSearchViewModel {
    
    @Published private var sections: [NewSearchSectionConfiguration] = []
    
    private var tags: [Relation.Tag.Option] = [] {
        didSet {
            sections = makeSections()
        }
    }
    
    private var selectedTagIds: [String] = [] {
        didSet {
            sections = makeSections()
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
    
    func handleRowsSelect(rowIds: [String]) {
        selectedTagIds = rowIds
    }
    
}

private extension TagsSearchViewModel {
    
    func makeSections() -> [NewSearchSectionConfiguration] {
        NewSearchSectionsBuilder.makeSections(tags) { [weak self] tags in
            guard let self = self else { return [] }
            
            return self.rowConfigurations(from: tags, selectedTagIds: self.selectedTagIds)
        }
    }
    
    func rowConfigurations(from tags: [Relation.Tag.Option], selectedTagIds: [String]) -> [NewSearchRowConfiguration] {
        tags.map { tag in
            NewSearchRowConfiguration(
                id: tag.id,
                rowContentHash: tag.hashValue
            ) {
                TagSearchRowView(
                    viewModel: tag.asTagViewModel,
                    guidlines: RelationStyle.regular(allowMultiLine: false).tagViewGuidlines,
                    selectionIndicatorViewModel: SelectionIndicatorViewModelBuilder.buildModel(id: tag.id, selectedIds: selectedTagIds)
                ).eraseToAnyView()
            }
        }
    }
    
}

private extension Relation.Tag.Option {
    
    var asTagViewModel: TagView.Model {
        TagView.Model(text: text, textColor: textColor, backgroundColor: backgroundColor)
    }
    
}
