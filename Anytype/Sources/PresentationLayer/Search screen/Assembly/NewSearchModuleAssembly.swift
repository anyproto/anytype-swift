import Foundation

final class NewSearchModuleAssembly: NewSearchModuleAssemblyProtocol {
 
    static func statusSearchModule(
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
    
    static func tagsSearchModule(
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
    
    static func objectsSearchModule(
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
            searchService: SearchService(),
            excludedObjectIds: excludedObjectIds,
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
    
    static func filesSearchModule(
        excludedFileIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = FilesSearchInteractor(
            searchService: SearchService(),
            excludedFileIds: excludedFileIds
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
    
    static func changeObjectTypeSearchModule(
        title: String,
        excludedObjectTypeId: String?,
        onSelect: @escaping (_ id: String) -> Void
    ) -> NewSearchView {
        let interactor = ObjectTypesSearchInteractor(
            searchService: SearchService(),
            excludedObjectTypeId: excludedObjectTypeId
        )
        
        let internalViewModel = ObjectTypesSearchViewModel(interactor: interactor)
        let viewModel = NewSearchViewModel(
            title: title,
            selectionMode: .singleItem,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        ) { ids in
            guard let id = ids.first else { return }
            onSelect(id)
        }
        
        return NewSearchView(viewModel: viewModel)
    }
    
}
