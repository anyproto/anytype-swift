import Foundation

struct ObjectsOptionsSearchModuleBuilder: RelationOptionsSearchModuleBuilderProtocol {
    
    func buildModule(
        excludedOptionIds: [String],
        onSelect: @escaping ([String]) -> Void,
        onCreate _ : @escaping (String) -> Void
    ) -> NewSearchView {
        NewSearchModuleAssembly.buildObjectsSearchModule(
            selectedObjectIds: excludedOptionIds,
            onSelect: onSelect
        )
    }
    
}
