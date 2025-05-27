import Foundation
import Services
import AnytypeCore

protocol SetPermissionsBuilderProtocol: AnyObject {
    func build(setDocument: SetDocument, participantCanEdit: Bool) -> SetPermissions
}

final class SetPermissionsBuilder: SetPermissionsBuilderProtocol {
    
    func build(setDocument: SetDocument, participantCanEdit: Bool) -> SetPermissions {
        
        let isVersionMode = setDocument.mode.isVersion
        let isArchive = setDocument.details?.isArchived ?? true
        let isLocked = setDocument.document.isLocked
        let canEdit = !isLocked && !isArchive && participantCanEdit && !isVersionMode
        
        return SetPermissions(
            canCreateObject: canEdit && canCreateObject(setDocument: setDocument),
            canEditView: canEdit,
            canTurnSetIntoCollection: canEdit && !setDocument.isCollection(),
            canChangeQuery: canEdit && !setDocument.isCollection(),
            canEditRelationValuesInView: canEdit && canEditRelationValuesInView(setDocument: setDocument),
            canEditTitle: canEdit,
            canEditDescription: canEdit,
            canEditSetObjectIcon: canEdit
        )
    }
    
    private func canCreateObject(setDocument: SetDocument) -> Bool {
        guard let details = setDocument.details else {
            anytypeAssertionFailure("SetDocument: No details in canCreateObject")
            return false
        }
        
        if details.isList {
            return canCreateObjectOfList(setDocument: setDocument, details: details)
        } else if details.isObjectType {
            return canCreateObjectOfType(ObjectType(details: details))
        } else {
            return false
        }
        
    }
    
    private func canCreateObjectOfList(setDocument: SetDocument, details: ObjectDetails) -> Bool {
        if details.isCollection { return true }
        if setDocument.isSetByRelation() { return true }
        
        // Set query validation
        // Create objects in sets by type only permitted if type is Page-like
        guard let setOfId = details.filteredSetOf.first else {
            return false
        }
        
        guard let queryType = try? ObjectTypeProvider.shared.objectType(id: setOfId) else {
            return false
        }
        
        return canCreateObjectOfType(queryType)
    }
    
    private func canCreateObjectOfType(_ type: ObjectType) -> Bool {
        guard let layout = type.recommendedLayout else {
            return false
        }
        
        if type.isTemplateType {
            return false
        }

        return layout.isSupportedForCreationInSets

    }
    
    private func canEditRelationValuesInView(setDocument: some SetDocumentProtocol) -> Bool {
        let activeView = setDocument.activeView
        let viewRelationValueIsLocked = activeView.type == .gallery ||
            activeView.type == .list ||
            (FeatureFlags.setKanbanView && activeView.type == .kanban)

        return !viewRelationValueIsLocked && setDocument.document.permissions.canEditRelationValues
    }
}
