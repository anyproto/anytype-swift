import Foundation
import BlocksModels

final class NewSearchModuleAssembly: NewSearchModuleAssemblyProtocol {
 
    static func statusSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .singleItem,
        allStatuses: [Relation.Status.Option],
        selectedStatusesIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = StatusSearchInteractor(
            allStatuses: allStatuses,
            selectedStatusesIds: selectedStatusesIds,
            isPreselectModeAvailable: selectionMode.isPreselectModeAvailable
        )
        
        let internalViewModel = StatusSearchViewModel(selectionMode: selectionMode, interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: style.isCreationModeAvailable ? .available(action: onCreate) : .unavailable,
            selectionMode: selectionMode,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func tagsSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .multipleItems(),
        allTags: [Relation.Tag.Option],
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        let interactor = TagsSearchInteractor(
            allTags: allTags,
            selectedTagIds: selectedTagIds,
            isPreselectModeAvailable: selectionMode.isPreselectModeAvailable
        )
        
        let internalViewModel = TagsSearchViewModel(selectionMode: selectionMode, interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: style.isCreationModeAvailable ? .available(action: onCreate) : .unavailable,
            selectionMode: selectionMode,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func objectsSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .multipleItems(),
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = ObjectsSearchInteractor(
            searchService: SearchService(),
            excludedObjectIds: excludedObjectIds,
            limitedObjectType: limitedObjectType
        )
        
        let internalViewModel = ObjectsSearchViewModel(selectionMode: selectionMode, interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: .unavailable,
            selectionMode: selectionMode,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func filesSearchModule(
        style: NewSearchView.Style = .default,
        excludedFileIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        let interactor = FilesSearchInteractor(
            searchService: SearchService(),
            excludedFileIds: excludedFileIds
        )
        
        let internalViewModel = ObjectsSearchViewModel(selectionMode: .multipleItems(), interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        return NewSearchView(viewModel: viewModel)
    }
    
    static func objectTypeSearchModule(
        style: NewSearchView.Style = .default,
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
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        ) { ids in
            guard let id = ids.first else { return }
            onSelect(id)
        }
        
        return NewSearchView(viewModel: viewModel)
    }
    
    static func multiselectObjectTypesSearchModule(
        style: NewSearchView.Style = .default,
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
            title: Loc.limitObjectTypes,
            style: style,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel,
            onSelect: onSelect
        )
        
        return NewSearchView(viewModel: viewModel)
    }
    
    static func moveToObjectSearchModule(
        style: NewSearchView.Style = .default,
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
            style: style,
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
        style: NewSearchView.Style = .default,
        relations: [RelationMetadata],
        onSelect: @escaping (_ id: String) -> Void
    ) -> NewSearchView {
        let interactor = SetSortsSearchInteractor(relations: relations)
        
        let internalViewModel = SetSortsSearchViewModel(interactor: interactor)
        
        let viewModel = NewSearchViewModel(
            searchPlaceholder: Loc.EditSorts.Popup.Sort.Add.searchPlaceholder,
            style: style,
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
