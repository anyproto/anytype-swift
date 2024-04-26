import Foundation

class ObjectsOptionsSearchModuleBuilder: RelationOptionsSearchModuleBuilderProtocol {
    
    let limitedObjectType: [String]
    private let newSearcModuleAssembly: NewSearchModuleAssemblyProtocol
    
    init(limitedObjectType: [String], newSearcModuleAssembly: NewSearchModuleAssemblyProtocol) {
        self.limitedObjectType = limitedObjectType
        self.newSearcModuleAssembly = newSearcModuleAssembly
    }
    
    // MARK: - RelationOptionsSearchModuleBuilderProtocol
    
    func buildModule(
        spaceId: String,
        excludedOptionIds: [String],
        onSelect: @escaping ([String]) -> Void,
        onCreate _ : @escaping (String) -> Void
    ) -> NewSearchView {
        newSearcModuleAssembly.objectsSearchModule(
            spaceId: spaceId,
            excludedObjectIds: excludedOptionIds,
            limitedObjectType: limitedObjectType,
            onSelect: { details in onSelect(details.map(\.id)) }
        )
    }
    
}
