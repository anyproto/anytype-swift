import Foundation
import Services

struct ObjectPermissions: Equatable {
    
    let canChangeType: Bool
    let canDelete: Bool
    let canTemplateSetAsDefault: Bool
    let canArchive: Bool
    let canDuplicate: Bool
    let canUndoRedo: Bool
    let canMakeAsTemplate: Bool
    let canCreateWidget: Bool
    let canFavorite: Bool
    let canLinkItself: Bool
    let canLock: Bool
    let canChangeIcon: Bool
    let canChangeCover: Bool
    let canChangeLayout: Bool
    let canEditRelationValues: Bool
    let canEditRelationsList: Bool
    let canApplyTemplates: Bool
    let canEditBlocks: Bool
    let editBlocks: EditBlocksPermission
    
    init(
        details: ObjectDetails,
        isLocked: Bool,
        participantCanEdit: Bool,
        objectRestrictions: [ObjectRestriction]
    ) {
        let isArchive = details.isArchived
        let isTemplateType = details.isTemplateType
        
        let canEdit = !isLocked && !isArchive && participantCanEdit
        let canApplyUneditableActions = participantCanEdit && !isArchive
        
        let specificTypes = details.layoutValue != .set
                            && details.layoutValue != .collection
                            && details.layoutValue != .participant
        
        self.canChangeType = !objectRestrictions.contains(.typeChange) && canEdit && !isTemplateType
        self.canDelete = isArchive && participantCanEdit
        self.canTemplateSetAsDefault = isTemplateType && canEdit
        self.canArchive = !objectRestrictions.contains(.delete) && participantCanEdit
        self.canDuplicate = !objectRestrictions.contains(.duplicate) && canApplyUneditableActions
        
        self.canUndoRedo = specificTypes && canEdit
        
        self.canMakeAsTemplate = details.canMakeTemplate
                                && !objectRestrictions.contains(.template)
                                && canApplyUneditableActions
        
        self.canCreateWidget = details.isVisibleLayout
                                && !isTemplateType
                                && details.layoutValue != .participant
                                && canApplyUneditableActions
        
        self.canFavorite = canApplyUneditableActions && !isTemplateType
        self.canLinkItself = canApplyUneditableActions && !isTemplateType
        self.canLock = specificTypes && canApplyUneditableActions && !isTemplateType
        self.canChangeIcon = DetailsLayout.layoutsWithIcon.contains(details.layoutValue) && canEdit
        self.canChangeCover = DetailsLayout.layoutsWithCover.contains(details.layoutValue) && canEdit
        self.canChangeLayout = DetailsLayout.layoutsWithChangeLayout.contains(details.layoutValue) && canEdit
        self.canEditRelationValues = canEdit && !objectRestrictions.contains(.details)
        self.canEditRelationsList = canEdit && !objectRestrictions.contains(.relations)
        self.canApplyTemplates = canEdit && !isTemplateType
        
        if isLocked {
            self.editBlocks = .readonly(.locked)
        } else if isArchive {
            self.editBlocks = .readonly(.archived)
        } else if !participantCanEdit {
            self.editBlocks = .readonly(.spaceIsReadonly)
        } else if objectRestrictions.contains(.blocks) {
            self.editBlocks = .readonly(.restrictions)
        } else {
            self.editBlocks = .edit
        }
        
        self.canEditBlocks = editBlocks.canEdit
    }
}

extension ObjectDetails {
    
    func permissions(particioant: Participant?) -> ObjectPermissions {
        permissions(participantCanEdit: particioant?.canEdit ?? false)
    }
    
    func permissions(participantCanEdit: Bool) -> ObjectPermissions {
        ObjectPermissions(
            details: self,
            isLocked: false,
            participantCanEdit: participantCanEdit,
            objectRestrictions: restrictionsValue
        )
    }
}
