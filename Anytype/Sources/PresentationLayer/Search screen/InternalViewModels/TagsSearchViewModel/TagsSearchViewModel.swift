import Foundation
import Combine
import SwiftUI

final class TagsSearchViewModel {
    
    let selectionMode: LegacySearchViewModel.SelectionMode
    
    private let viewStateSubject = PassthroughSubject<LegacySearchViewState, Never> ()
    private var tags: [Relation.Tag.Option] = []
    private var selectedTagIds: [String] = []
    
    private let interactor: TagsSearchInteractor
    private let onSelect: (_ ids: [String]) -> Void
    
    init(
        selectionMode: LegacySearchViewModel.SelectionMode,
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
    
    var viewStatePublisher: AnyPublisher<LegacySearchViewState, Never> { viewStateSubject.eraseToAnyPublisher() }
    
    func search(text: String) async throws {
        let resultTags = try await interactor.search(text: text)
        self.tags = resultTags
        handleSearchedTags()
    }
    
    func handleRowsSelection(ids: [String]) {
        guard tags.isNotEmpty else { return }
        
        selectedTagIds = ids
        handleSearchedTags()
    }
    
    func handleConfirmSelection(ids: [String]) {
        onSelect(ids)
    }
    
    func createButtonModel(searchText: String) -> LegacySearchViewModel.CreateButtonModel {
        return interactor.isCreateButtonAvailable(searchText: searchText, tags: tags)
            ? .enabled(title:  Loc.createOptionWith(searchText))
            : .disabled
    }
    
}

private extension TagsSearchViewModel {
    
    func handleSearchedTags() {
        let sections = makeSections(tags: tags, selectedTagIds: selectedTagIds)
        viewStateSubject.send(.resultsList(.sectioned(sectinos: sections)))
    }
    
    func makeSections(tags: [Relation.Tag.Option], selectedTagIds: [String]) -> [ListSectionConfiguration] {
        LegacySearchSectionsBuilder.makeSections(tags) {
            $0.asRowConfigurations(with: selectedTagIds)
        }
    }
    
}

private extension Array where Element == Relation.Tag.Option {
    
    func asRowConfigurations(with selectedTagIds: [String]) -> [ListRowConfiguration] {
        let style = PropertyStyle.regular(allowMultiLine: false)
        return map { tag in
            ListRowConfiguration(
                id: tag.id,
                contentHash: tag.hashValue
            ) {
                TagSearchRowView(
                    config: TagView.Config(
                        text: tag.text,
                        textColor: tag.textColor,
                        backgroundColor: tag.backgroundColor,
                        textFont: style.font,
                        guidlines: style.tagViewGuidlines
                    ),
                    selectionIndicatorViewModel: SelectionIndicatorViewModelBuilder.buildModel(id: tag.id, selectedIds: selectedTagIds)
                ).eraseToAnyView()
            }
        }
    }
}
