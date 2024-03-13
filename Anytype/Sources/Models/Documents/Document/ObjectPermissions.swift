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
        objectRestrictions: ObjectRestrictions
    ) {
        let isArchive = details.isArchived
        let isTemplateType = details.isTemplateType
        
        let canEdit = !isLocked && !isArchive && participantCanEdit
        
        let specificTypes = details.layoutValue != .set
                            && details.layoutValue != .collection
                            && details.layoutValue != .participant
        
        self.canChangeType = !objectRestrictions.objectRestriction.contains(.typeChange) && canEdit
        self.canDelete = !isArchive && participantCanEdit
        self.canTemplateSetAsDefault = isTemplateType && canEdit
        self.canArchive = !objectRestrictions.objectRestriction.contains(.delete) && participantCanEdit
        self.canDuplicate = !objectRestrictions.objectRestriction.contains(.duplicate) && participantCanEdit
        
        self.canUndoRedo = specificTypes && participantCanEdit
        
        self.canMakeAsTemplate = details.canMakeTemplate
                                && !objectRestrictions.objectRestriction.contains(.template)
                                && participantCanEdit
        
        self.canCreateWidget = details.isVisibleLayout
                                && !details.isTemplateType
                                && details.layoutValue != .participant
                                && participantCanEdit
        
        self.canFavorite = participantCanEdit
        self.canLinkItself = participantCanEdit
        self.canLock = specificTypes && participantCanEdit
        self.canChangeIcon = DetailsLayout.layoutsWithIcon.contains(details.layoutValue) && canEdit
        self.canChangeCover = DetailsLayout.layoutsWithCover.contains(details.layoutValue) && canEdit
        self.canChangeLayout = DetailsLayout.layoutsWithChangeLayout.contains(details.layoutValue) && canEdit
        self.canEditRelationValues = canEdit && !objectRestrictions.objectRestriction.contains(.details)
        self.canEditRelationsList = canEdit && !objectRestrictions.objectRestriction.contains(.relations)
        self.canApplyTemplates = canEdit
        
        if isLocked {
            self.editBlocks = .readonly(.locked)
        } else if isArchive {
            self.editBlocks = .readonly(.archived)
        } else if !participantCanEdit {
            self.editBlocks = .readonly(.spaceIsReadonly)
        } else if objectRestrictions.objectRestriction.contains(.blocks) {
            self.editBlocks = .readonly(.restrictions)
        } else {
            self.editBlocks = .edit
        }
        
        self.canEditBlocks = editBlocks.canEdit
    }
}
