import Foundation

final class TagRelationOptionSearchViewModel: ObservableObject {
    
    @Published var selectedTagIds: [String] = []
    @Published var sections: [RelationOptionsSection<Relation.Tag.Option>]
    
    private let source: RelationSource
    private let availableTags: [Relation.Tag.Option]
    private let relation: Relation
    private let service: RelationsServiceProtocol
    private let addTagsAction: ([String]) -> Void
    
    init(
        source: RelationSource,
        availableTags: [Relation.Tag.Option],
        relation: Relation,
        service: RelationsServiceProtocol,
        addTagsAction: @escaping ([String]) -> Void
    ) {
        self.source = source
        self.availableTags = availableTags
        self.relation = relation
        self.service = service
        
        self.addTagsAction = addTagsAction
        
        self.sections = RelationOptionsSectionBuilder.sections(from: availableTags)
    }
    
}

extension TagRelationOptionSearchViewModel {
    
    func filterTag(text: String) {
        guard text.isNotEmpty else {
            self.sections = RelationOptionsSectionBuilder.sections(from: availableTags)
            return
        }
        
        let filteredTags: [Relation.Tag.Option] = availableTags.filter {
            guard $0.text.isNotEmpty else { return false }
            
            return $0.text.lowercased().contains(text.lowercased())
        }
        
        self.sections = RelationOptionsSectionBuilder.sections(from: filteredTags)
    }
    
    func didTapAddSelectedTags() {
        addTagsAction(selectedTagIds)
    }
    
    func createOption(text: String) {
        let optionId = service.addRelationOption(source: source, relationKey: relation.id, optionText: text)
        guard let optionId = optionId else { return}

        addTagsAction([optionId])
    }
    
}
