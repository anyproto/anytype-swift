import Foundation

struct TagsOptionsSearchModuleBuilder {
    
    let relationKey: String
    
}

extension TagsOptionsSearchModuleBuilder: RelationOptionsSearchModuleBuilderProtocol {
    
    func buildModule(
        excludedOptionIds: [String],
        onSelect: @escaping ([String]) -> Void,
        onCreate: @escaping (String) -> Void
    ) -> NewSearchView {
        NewSearchModuleAssembly.tagsSearchModule(relationKey: relationKey, selectedTagIds: excludedOptionIds, onSelect: onSelect, onCreate: onCreate)
    }
    
}
