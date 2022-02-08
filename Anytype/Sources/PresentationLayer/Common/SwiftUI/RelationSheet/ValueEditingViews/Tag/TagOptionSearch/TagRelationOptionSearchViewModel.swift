import Foundation

final class TagRelationOptionSearchViewModel: ObservableObject {
    
    @Published var selectedTagIds: [String] = []
    @Published var sections: [RelationOptionsSection<Relation.Tag.Option>]
    
    private let relationKey: String
    private let availableTags: [Relation.Tag.Option]
    private let addTagsAction: ([String]) -> Void
    private let relationsService: RelationsServiceProtocol
    
    init(
        relationKey: String,
        availableTags: [Relation.Tag.Option],
        relationsService: RelationsServiceProtocol,
        addTagsAction: @escaping ([String]) -> Void
    ) {
        self.relationKey = relationKey
        self.availableTags = availableTags
        self.relationsService = relationsService
        self.addTagsAction = addTagsAction
        
        self.sections = RelationOptionsSectionBuilder.sections(from: availableTags, filterText: nil)
    }
    
}

extension TagRelationOptionSearchViewModel {
    
    func filterTagSections(text: String) {
        self.sections = RelationOptionsSectionBuilder.sections(from: availableTags, filterText: text)
    }
    
    func didTapOnTag(_ tag: Relation.Tag.Option) {
        let id = tag.id
        if selectedTagIds.contains(id) {
            selectedTagIds = selectedTagIds.filter { $0 != id }
        } else {
            selectedTagIds.append(id)
        }
    }
    
    func didTapAddSelectedTags() {
        addTagsAction(selectedTagIds)
    }
    
    func createOption(text: String) {
        let optionId = relationsService.addRelationOption(relationKey: relationKey, optionText: text)
        guard let optionId = optionId else { return}

        addTagsAction([optionId])
    }
    
}
