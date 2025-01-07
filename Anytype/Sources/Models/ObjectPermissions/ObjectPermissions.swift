import Foundation
import Services

struct ObjectPermissions: Equatable {
    var canChangeType: Bool = false
    var canDelete: Bool = false
    var canTemplateSetAsDefault: Bool = false
    var canArchive: Bool = false
    var canDuplicate: Bool = false
    var canUndoRedo: Bool = false
    var canMakeAsTemplate: Bool = false
    var canCreateWidget: Bool = false
    var canFavorite: Bool = false
    var canLinkItself: Bool = false
    var canLock: Bool = false
    var canChangeIcon: Bool = false
    var canChangeCover: Bool = false
    var canChangeLayout: Bool = false
    var canEditRelationValues: Bool = false
    var canEditRelationsList: Bool = false
    var canApplyTemplates: Bool = false
    var canShare: Bool = false
    var canEditBlocks: Bool = false
    var canEditMessages: Bool = false
    var canShowVersionHistory: Bool = false
    var canRestoreVersionHistory: Bool = false
    var canEditDetails: Bool = false
    var editBlocks: EditBlocksPermission = .readonly(.restrictions)
}

extension ObjectPermissions {
    init(
        details: ObjectDetails,
        isLocked: Bool,
        participantCanEdit: Bool,
        isVersionMode: Bool,
        objectRestrictions: [ObjectRestriction]
    ) {
        let isArchive = details.isArchived
        let isTemplateType = details.isTemplateType
        
        let caEditRelations = !isLocked && !isArchive && participantCanEdit && !isVersionMode
        let canEdit = caEditRelations && !details.layoutValue.isFileOrMedia
        let canApplyUneditableActions = participantCanEdit && !isArchive
        
        let specificTypes = !details.layoutValue.isList && !details.layoutValue.isParticipant
        
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
        self.canChangeIcon = details.layoutValue.haveIcon && canEdit
        self.canChangeCover = details.layoutValue.haveCover && canEdit
        self.canChangeLayout = details.layoutValue.isEditorLayout && canEdit // && !objectRestrictions.contains(.layoutChange)
        self.canEditDetails = !objectRestrictions.contains(.details)
        self.canEditRelationValues = caEditRelations && canEditDetails
        self.canEditRelationsList = canEditRelationValues && !objectRestrictions.contains(.relations)
        self.canShare = !isTemplateType
        self.canApplyTemplates = canEdit && !isTemplateType
        self.canEditMessages = canEdit
        
        if isLocked || isVersionMode {
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
        self.canShowVersionHistory = details.isVisibleLayout
                                    && details.layoutValue != .participant
                                    && !details.templateIsBundled
        self.canRestoreVersionHistory = !isLocked && !isArchive && participantCanEdit
    }
}

extension ObjectDetails {
    
    func permissions(participant: Participant?) -> ObjectPermissions {
        permissions(participantCanEdit: participant?.canEdit ?? false)
    }
    
    func permissions(participantCanEdit: Bool) -> ObjectPermissions {
        ObjectPermissions(
            details: self,
            isLocked: false,
            participantCanEdit: participantCanEdit, 
            isVersionMode: false,
            objectRestrictions: restrictionsValue
        )
    }
}
