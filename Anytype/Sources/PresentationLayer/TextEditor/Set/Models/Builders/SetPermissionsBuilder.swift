import Foundation
import Services
import AnytypeCore

protocol SetPermissionsBuilderProtocol: AnyObject {
    func build(setDocument: SetDocument, participantCanEdit: Bool) -> SetPermissions
}

final class SetPermissionsBuilder: SetPermissionsBuilderProtocol {
    
    func build(setDocument: SetDocument, participantCanEdit: Bool) -> SetPermissions {
        
        let isArchive = setDocument.details?.isArchived ?? true
        let isLocked = setDocument.document.isLocked
        let canEdit = !isLocked && !isArchive && participantCanEdit
        
        return SetPermissions(
            canCreateObject: canEdit && canCreateObject(setDocument: setDocument, participantCanEdit: participantCanEdit),
            canEditView: canEdit,
            canTurnSetIntoCollection: canEdit && !setDocument.isCollection(),
            canChangeQuery: canEdit && !setDocument.isCollection(),
            canEditRelationValuesInView: canEdit && canEditRelationValuesInView(setDocument: setDocument)
        )
    }
    
    private func canCreateObject(setDocument: SetDocument, participantCanEdit: Bool) -> Bool {
        
        guard let details = setDocument.details else {
            anytypeAssertionFailure("SetDocument: No details in canCreateObject")
            return false
        }
        guard details.isList else { return false }
        
        if details.isCollection { return true }
        if setDocument.isSetByRelation() { return true }
        
        // Set query validation
        // Create objects in sets by type only permitted if type is Page-like
        guard let setOfId = details.setOf.first(where: { $0.isNotEmpty }) else {
            return false
        }
        
        guard let layout = try? ObjectTypeProvider.shared.objectType(id: setOfId).recommendedLayout else {
            return false
        }
        
        return DetailsLayout.supportedForCreationInSets.contains(layout)
    }
    
    private func canEditRelationValuesInView(setDocument: SetDocumentProtocol) -> Bool {
        let activeView = setDocument.activeView
        let viewRelationValueIsLocked = activeView.type != .gallery ||
            activeView.type == .list ||
            (FeatureFlags.setKanbanView && activeView.type == .kanban)

        return !viewRelationValueIsLocked && setDocument.document.permissions.canEditRelationValues
    }
}
