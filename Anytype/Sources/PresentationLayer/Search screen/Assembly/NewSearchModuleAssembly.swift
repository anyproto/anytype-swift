import Foundation

final class NewSearchModuleAssembly: NewSearchModuleAssemblyProtocol {
 
    static func buildStatusSearchModule(
        allStatuses: [Relation.Status.Option],
        selectedStatus: Relation.Status.Option?,
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = StatusSearchInteractor(
            allStatuses: allStatuses,
            selectedStatus: selectedStatus
        )
        
        let internalViewModel = StatusSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(
            selectionMode: .singleItem,
            itemCreationMode: .available(action: onCreate),
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func buildTagsSearchModule(
        allTags: [Relation.Tag.Option],
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = TagsSearchInteractor(
            allTags: allTags,
            selectedTagIds: selectedTagIds
        )
        
        let internalViewModel = TagsSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(
            selectionMode: .multipleItems,
            itemCreationMode: .available(action: onCreate),
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func buildObjectsSearchModule(
        selectedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
            searchService: SearchService(),
            selectedObjectIds: selectedObjectIds,
            limitedObjectType: limitedObjectType
        )
        
        let internalViewModel = ObjectsSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(
            selectionMode: .multipleItems,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func buildFilesSearchModule(selectedObjectIds: [String], onSelect: @escaping (_ ids: [String]) -> Void) -> NewSearchView {
        let interactor = FilesSearchInteractor(
            searchService: SearchService(),
            selectedObjectIds: selectedObjectIds
        )
        
        let internalViewModel = ObjectsSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(
            selectionMode: .multipleItems,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
}
