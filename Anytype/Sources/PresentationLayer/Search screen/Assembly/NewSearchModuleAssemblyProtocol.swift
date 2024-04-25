import Foundation
import Services
import SwiftUI

protocol NewSearchModuleAssemblyProtocol {
    
    func statusSearchModule(
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
        spaceId: String,
        relationKey: String,
        selectedStatusesIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
    func tagsSearchModule(
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
        spaceId: String,
        relationKey: String,
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
    func objectsSearchModule(
        title: String?,
        spaceId: String,
        style: NewSearchView.Style,
        selectionMode: NewSearchViewModel.SelectionMode,
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ details: [ObjectDetails]) -> Void
    ) -> NewSearchView
    
    func filesSearchModule(
        spaceId: String,
        excludedFileIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    func multiselectObjectTypesSearchModule(
        selectedObjectTypeIds: [String],
        spaceId: String,
        onSelect: @escaping (_ ids: [String]) -> Void
    ) -> NewSearchView
    
    func setSortsSearchModule(
        relationsDetails: [RelationDetails],
        onSelect: @escaping (_ relation: RelationDetails) -> Void
    ) -> NewSearchView
    
    func relationsSearchModule(
        document: BaseDocumentProtocol,
        excludedRelationsIds: [String],
        target: RelationsModuleTarget,
        output: RelationSearchModuleOutput
    ) -> NewSearchView
}

// Extension for specific Settings
extension NewSearchModuleAssemblyProtocol {
    func statusSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .singleItem,
        spaceId: String,
        relationKey: String,
        selectedStatusesIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView  {
        return statusSearchModule(
            style: style,
            selectionMode: selectionMode,
            spaceId: spaceId,
            relationKey: relationKey,
            selectedStatusesIds: selectedStatusesIds,
            onSelect: onSelect,
            onCreate: onCreate
        )
    }
    
    func tagsSearchModule(
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .multipleItems(),
        spaceId: String,
        relationKey: String,
        selectedTagIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView {
        return tagsSearchModule(
            style: style,
            selectionMode: selectionMode,
            spaceId: spaceId,
            relationKey: relationKey,
            selectedTagIds: selectedTagIds,
            onSelect: onSelect,
            onCreate: onCreate
        )
    }
    
    func objectsSearchModule(
        title: String? = nil,
        spaceId: String,
        style: NewSearchView.Style = .default,
        selectionMode: NewSearchViewModel.SelectionMode = .multipleItems(),
        excludedObjectIds: [String],
        limitedObjectType: [String],
        onSelect: @escaping (_ details: [ObjectDetails]) -> Void
    ) -> NewSearchView {
        return objectsSearchModule(
            title: title,
            spaceId: spaceId,
            style: style,
            selectionMode: selectionMode,
            excludedObjectIds: excludedObjectIds,
            limitedObjectType: limitedObjectType,
            onSelect: onSelect
        )
    }
}
