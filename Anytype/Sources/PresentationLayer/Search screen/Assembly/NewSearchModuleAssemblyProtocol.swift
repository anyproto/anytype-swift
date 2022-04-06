import Foundation

protocol NewSearchModuleAssemblyProtocol {
    
    static func buildStatusSearchModule(
        allStatuses: [Relation.Status.Option],
        selectedStatus: Relation.Status.Option?,
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
    static func buildTagsSearchModule(
        allTags: [Relation.Tag.Option],
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
    static func buildObjectsSearchModule(
        selectedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    static func buildFilesSearchModule(
        selectedObjectIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
}
