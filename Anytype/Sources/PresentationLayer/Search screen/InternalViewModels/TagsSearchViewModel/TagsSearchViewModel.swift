import Foundation
import Combine
import SwiftUI

final class TagsSearchViewModel {
    
    let selectionMode: NewSearchViewModel.SelectionMode
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never> ()
    
    private var tags: [Relation.Tag.Option] = []
    private var selectedTagIds: [String] = []
    
    private let interactor: TagsSearchInteractor
    private let onSelect: (_ ids: [String]) -> Void
    
    init(
        selectionMode: NewSearchViewModel.SelectionMode,
        interactor: TagsSearchInteractor,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) {
        self.selectionMode = selectionMode
        self.interactor = interactor
        self.onSelect = onSelect
        self.setup()
    }
    
    private func setup() {
        if case let .multipleItems(preselectedIds) = selectionMode {
            self.selectedTagIds = preselectedIds
        }
    }
}

extension TagsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    func search(text: String) {
        let result = interactor.search(text: text)
        switch result {
        case .success(let tags):
            self.tags = tags
            handleSearchedTags()
        case .failure(let error):
            viewStateSubject.send(.error(error))
        }
    }
    
    func handleRowsSelection(ids: [String]) {
        guard tags.isNotEmpty else { return }
        
        selectedTagIds = ids
        handleSearchedTags()
    }
    
    func handleConfirmSelection(ids: [String]) {
        onSelect(ids)
    }
    
    func createButtonModel(searchText: String) -> NewSearchViewModel.CreateButtonModel {
        return interactor.isCreateButtonAvailable(searchText: searchText, tags: tags)
            ? .enabled(title:  Loc.createOption(searchText))
            : .disabled
    }
    
}

private extension TagsSearchViewModel {
    
    func handleSearchedTags() {
        let sections = makeSections(tags: tags, selectedTagIds: selectedTagIds)
        viewStateSubject.send(.resultsList(.sectioned(sectinos: sections)))
    }
    
    func makeSections(tags: [Relation.Tag.Option], selectedTagIds: [String]) -> [ListSectionConfiguration] {
        NewSearchSectionsBuilder.makeSections(tags) {
            $0.asRowConfigurations(with: selectedTagIds)
        }
    }
    
}

private extension Array where Element == Relation.Tag.Option {
    
    func asRowConfigurations(with selectedTagIds: [String]) -> [ListRowConfiguration] {
        map { tag in
            ListRowConfiguration(
                id: tag.id,
                contentHash: tag.hashValue
            ) {
                TagSearchRowView(
                    viewModel: tag.asTagViewModel,
                    relationStyle: .regular(allowMultiLine: false),
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
