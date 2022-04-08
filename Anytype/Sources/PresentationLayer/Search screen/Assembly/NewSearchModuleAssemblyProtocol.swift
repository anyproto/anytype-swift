import Foundation

protocol NewSearchModuleAssemblyProtocol {
    
    static func statusSearchModule(
        allStatuses: [Relation.Status.Option],
        selectedStatus: Relation.Status.Option?,
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
    static func tagsSearchModule(
        allTags: [Relation.Tag.Option],
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
    static func objectsSearchModule(
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    static func filesSearchModule(
        excludedFileIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    static func objectTypeSearchModule(
        title: String,
        excludedObjectTypeId: String?,
        onSelect: @escaping (_ id: String) -> Void
    ) -> NewSearchView
    
    static func multiselectObjectTypesSearchModule(
        selectedObjectTypeIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
}
