import Foundation
import BlocksModels

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
        
        let internalViewModel = ObjectsSearchViewModel(selectionMode: .multipleItems, interactor: interactor)
        let viewModel = NewSearchViewModel(
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
        
        let internalViewModel = ObjectsSearchViewModel(selectionMode: .multipleItems, interactor: interactor)
        let viewModel = NewSearchViewModel(
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func objectTypeSearchModule(
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
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        ) { ids in
            guard let id = ids.first else { return }
            onSelect(id)
        }
        
        return NewSearchView(viewModel: viewModel)
    }
    
    static func multiselectObjectTypesSearchModule(
        selectedObjectTypeIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectTypesSearchInteractor(
            searchService: SearchService(),
            excludedObjectTypeId: nil
        )
        
        let internalViewModel = MultiselectObjectTypesSearchViewModel(
            selectedObjectTypeIds: selectedObjectTypeIds,
            interactor: interactor
        )
        
        let viewModel = NewSearchViewModel(
            title: "Limit object types".localized,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        
        return NewSearchView(viewModel: viewModel)
    }
    
    static func moveToObjectSearchModule(
        title: String,
        excludedObjectIds: [String],
        onSelect: @escaping (_ id: String) -> Void
    ) -> NewSearchView {
        let interactor = MoveToSearchInteractor(
            searchService: SearchService(),
            excludedObjectIds: excludedObjectIds
        )

        let internalViewModel = ObjectsSearchViewModel(
            selectionMode: .singleItem,
            interactor: interactor
        )
        let viewModel = NewSearchViewModel(
            title: title,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: { ids in
                guard let id = ids.first else { return }
                onSelect(id)
            }
        )

        return NewSearchView(viewModel: viewModel)
    }
    
    static func setSortsSearchModule(
        relations: [RelationMetadata],
        onSelect: @escaping (_ id: String) -> Void
    ) -> NewSearchView {
        let interactor = SetSortsSearchInteractor(relations: relations)
        
        let internalViewModel = SetSortsSearchViewModel(interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            searchPlaceholder: "EditSorts.Popup.Sort.Add.SearchPlaceholder".localized,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: { ids in
                guard let id = ids.first else { return }
                onSelect(id)
            }
        )
        
        return NewSearchView(viewModel: viewModel)
    }
}
