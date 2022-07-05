import Foundation

protocol NewSearchModuleAssemblyProtocol {
    
    static func statusSearchModule(
        style: NewSearchView.Style,
        allStatuses: [Relation.Status.Option],
        selectedStatus: Relation.Status.Option?,
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
    static func tagsSearchModule(
        style: NewSearchView.Style,
        allTags: [Relation.Tag.Option],
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
    static func objectsSearchModule(
        style: NewSearchView.Style,
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    static func filesSearchModule(
        style: NewSearchView.Style,
        excludedFileIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    static func objectTypeSearchModule(
        style: NewSearchView.Style,
        title: String,
        excludedObjectTypeId: String?,
        onSelect: @escaping (_ id: String) -> Void
    ) -> NewSearchView
    
    static func multiselectObjectTypesSearchModule(
        style: NewSearchView.Style,
        selectedObjectTypeIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    static func moveToObjectSearchModule(
        style: NewSearchView.Style,
        title: String,
        excludedObjectIds: [String],
        onSelect: @escaping (_ id: String) -> Void
    ) -> NewSearchView
}
