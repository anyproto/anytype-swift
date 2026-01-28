import Services
import AnytypeCore

protocol ObjectSettingsBuilderProtocol {
    func build(details: ObjectDetails, permissions: ObjectPermissions, spaceUxType: SpaceUxType?, chatNotificationMode: SpacePushNotificationsMode?) -> [ObjectSetting]
}

final class ObjectSettingsBuilder: ObjectSettingsBuilderProtocol {
    @Injected(\.objectSettingsConflictManager)
    private var conflictManager: any ObjectSettingsPrimitivesConflictManagerProtocol
    
    func build(details: ObjectDetails, permissions: ObjectPermissions, spaceUxType: SpaceUxType?, chatNotificationMode: SpacePushNotificationsMode?) -> [ObjectSetting] {
        let canShowVersionHistory = details.isVisibleLayout(spaceUxType: spaceUxType)
            && details.resolvedLayoutValue != .participant
            && !details.resolvedLayoutValue.isChat
            && !details.templateIsBundled
            && !details.isObjectType

        let canShowNotifications = details.resolvedLayoutValue.isChat
            && spaceUxType?.supportsMultiChats == true

        return .builder {
           
            if permissions.canChangeIcon {
                ObjectSetting.icon
            }
            
            if permissions.canChangeCover {
                ObjectSetting.cover
            }

            if permissions.canToggleDescription {
                let isFeatured = details.featuredRelations.contains { $0 == BundledPropertyKey.description.rawValue }
                ObjectSetting.description(isVisible: isFeatured)
            }
            
            if permissions.canShowRelations {
                ObjectSetting.relations
            }
            
            if conflictManager.haveLayoutConflicts(details: details) {
                ObjectSetting.resolveConflict
            }
            
            if permissions.canPublish {
                ObjectSetting.webPublishing
            }

            if canShowNotifications, let chatNotificationMode {
                ObjectSetting.notifications(mode: chatNotificationMode)
            }

            if canShowVersionHistory {
                ObjectSetting.history
            }
            
        }
    }
}

extension Container {
    var objectSettingsBuilder: Factory<any ObjectSettingsBuilderProtocol> {
        self { ObjectSettingsBuilder() }.shared
    }
}
