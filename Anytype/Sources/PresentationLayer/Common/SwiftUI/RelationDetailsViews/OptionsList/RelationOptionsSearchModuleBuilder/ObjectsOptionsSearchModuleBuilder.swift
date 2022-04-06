import Foundation

struct ObjectsOptionsSearchModuleBuilder {
    
    let limitedObjectType: [String]
    
}

extension ObjectsOptionsSearchModuleBuilder: RelationOptionsSearchModuleBuilderProtocol {
    
    func buildModule(
        excludedOptionIds: [String],
        onSelect: @escaping ([String]) -> Void,
        onCreate _ : @escaping (String) -> Void
    ) -> NewSearchView {
        NewSearchModuleAssembly.objectsSearchModule(
            excludedObjectIds: excludedOptionIds,
            limitedObjectType: limitedObjectType,
            onSelect: onSelect
        )
    }
    
}
