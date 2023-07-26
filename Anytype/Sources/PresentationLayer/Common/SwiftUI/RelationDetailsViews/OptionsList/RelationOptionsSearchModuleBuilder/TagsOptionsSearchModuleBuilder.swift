import Foundation

class TagsOptionsSearchModuleBuilder: RelationOptionsSearchModuleBuilderProtocol {
    
    let relationKey: String
    private let newSearcModuleAssembly: NewSearchModuleAssemblyProtocol
    
    init(relationKey: String, newSearcModuleAssembly: NewSearchModuleAssemblyProtocol) {
        self.relationKey = relationKey
        self.newSearcModuleAssembly = newSearcModuleAssembly
    }
    
    // MARK: - RelationOptionsSearchModuleBuilderProtocol
    
    func buildModule(
        spaceId: String,
        excludedOptionIds: [String],
        onSelect: @escaping ([String]) -> Void,
        onCreate: @escaping (String) -> Void
    ) -> NewSearchView {
        newSearcModuleAssembly.tagsSearchModule(spaceId: spaceId, relationKey: relationKey, selectedTagIds: excludedOptionIds, onSelect: onSelect, onCreate: onCreate)
    }
    
}
