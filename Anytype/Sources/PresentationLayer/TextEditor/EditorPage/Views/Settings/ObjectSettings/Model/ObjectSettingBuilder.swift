import Services
import AnytypeCore

protocol ObjectSettingsBuilderProtocol {
    @available(*, deprecated, message: "Use spaceType overload instead")
    func build(details: ObjectDetails, permissions: ObjectPermissions, spaceUxType: SpaceUxType?, chatNotificationMode: SpacePushNotificationsMode?) -> [ObjectSetting]
    func build(details: ObjectDetails, permissions: ObjectPermissions, spaceType: SpaceType?, chatNotificationMode: SpacePushNotificationsMode?) -> [ObjectSetting]
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
            && !details.isArchived

        return buildSettings(
            details: details,
            permissions: permissions,
            canShowVersionHistory: canShowVersionHistory,
            canShowNotifications: canShowNotifications,
            chatNotificationMode: chatNotificationMode
        )
    }

    func build(details: ObjectDetails, permissions: ObjectPermissions, spaceType: SpaceType?, chatNotificationMode: SpacePushNotificationsMode?) -> [ObjectSetting] {
        let canShowVersionHistory = details.isVisibleLayout(spaceType: spaceType)
            && details.resolvedLayoutValue != .participant
            && !details.resolvedLayoutValue.isChat
            && !details.templateIsBundled
            && !details.isObjectType

        let canShowNotifications = details.resolvedLayoutValue.isChat
            && spaceType != .oneToOne
            && !details.isArchived

        return buildSettings(
            details: details,
            permissions: permissions,
            canShowVersionHistory: canShowVersionHistory,
            canShowNotifications: canShowNotifications,
            chatNotificationMode: chatNotificationMode
        )
    }

    private func buildSettings(
        details: ObjectDetails,
        permissions: ObjectPermissions,
        canShowVersionHistory: Bool,
        canShowNotifications: Bool,
        chatNotificationMode: SpacePushNotificationsMode?
    ) -> [ObjectSetting] {
        .builder {

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

            if details.isTemplate && permissions.canEditDetails {
                ObjectSetting.prefillName(isEnabled: details.isTemplateNamePrefilled)
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
