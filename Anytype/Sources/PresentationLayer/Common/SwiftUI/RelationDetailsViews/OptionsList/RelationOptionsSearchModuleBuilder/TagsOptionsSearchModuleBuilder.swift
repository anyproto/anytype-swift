import Foundation

struct TagsOptionsSearchModuleBuilder {
    
    let allTags: [Relation.Tag.Option]
    
}

extension TagsOptionsSearchModuleBuilder: RelationOptionsSearchModuleBuilderProtocol {
    
    func buildModule(
        excludedOptionIds: [String],
        onSelect: @escaping ([String]) -> Void,
        onCreate: @escaping (String) -> Void
    ) -> NewSearchView {
        NewSearchModuleAssembly.tagsSearchModule(allTags: allTags, selectedTagIds: excludedOptionIds, onSelect: onSelect, onCreate: onCreate)
    }
    
}
