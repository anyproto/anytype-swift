import Foundation
import BlocksModels

protocol NewSearchModuleAssemblyProtocol {
    
    func statusSearchModule(
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
        relationKey: String,
        selectedStatusesIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
    func tagsSearchModule(
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
        relationKey: String,
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
    func objectsSearchModule(
        title: String?,
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    func filesSearchModule(
        excludedFileIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    func objectTypeSearchModule(
        style: NewSearchView.Style,
        title: String,
        selectedObjectId: BlockId?,
        excludedObjectTypeId: String?,
        showBookmark: Bool,
        showSet: Bool,
        browser: EditorBrowserController?,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> NewSearchView
    
    func multiselectObjectTypesSearchModule(
        selectedObjectTypeIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    func blockObjectsSearchModule(
        title: String,
        excludedObjectIds: [String],
        onSelect: @escaping (_ details: ObjectDetails) -> Void
    ) -> NewSearchView
    
    func setSortsSearchModule(
        relationsDetails: [RelationDetails],
        onSelect: @escaping (_ relation: RelationDetails) -> Void
    ) -> NewSearchView
    
    func relationsSearchModule(
        document: BaseDocumentProtocol,
        excludedRelationsIds: [String],
        mode: RelationsSearchMode,
        output: RelationSearchModuleOutput
    ) -> NewSearchView
}

// Extension for specific Settings
extension NewSearchModuleAssemblyProtocol {
    func statusSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .singleItem,
        relationKey: String,
        selectedStatusesIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView  {
        return statusSearchModule(
            style: style,
            selectionMode: selectionMode,
            relationKey: relationKey,
            selectedStatusesIds: selectedStatusesIds,
            onSelect: onSelect,
            onCreate: onCreate
        )
    }
    
    func tagsSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .multipleItems(),
        relationKey: String,
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        return tagsSearchModule(
            style: style,
            selectionMode: selectionMode,
            relationKey: relationKey,
            selectedTagIds: selectedTagIds,
            onSelect: onSelect,
            onCreate: onCreate
        )
    }
    
    func objectsSearchModule(
        title: String? = nil,
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .multipleItems(),
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView {
        return objectsSearchModule(
            title: title,
            style: style,
            selectionMode: selectionMode,
            excludedObjectIds: excludedObjectIds,
            limitedObjectType: limitedObjectType,
            onSelect: onSelect
        )
    }
    
    func objectTypeSearchModule(
        style: NewSearchView.Style = .default,
        title: String,
        selectedObjectId: BlockId? = nil,
        excludedObjectTypeId: String? = nil,
        showBookmark: Bool = false,
        showSet: Bool = false,
        browser: EditorBrowserController? = nil,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> NewSearchView {
        return objectTypeSearchModule(
            style: style,
            title: title,
            selectedObjectId: selectedObjectId,
            excludedObjectTypeId: excludedObjectTypeId,
            showBookmark: showBookmark,
            showSet: showSet,
            browser: browser,
            onSelect: onSelect
        )
    }
}
