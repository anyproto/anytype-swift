import Services
import AnytypeCore

final class ObjectSettingBuilder {
    func build(details: ObjectDetails, permissions: ObjectPermissions) -> [ObjectSetting] {
        .builder {
            if permissions.canChangeIcon {
                ObjectSetting.icon
            }
            
            if permissions.canChangeCover {
                ObjectSetting.cover
            }
            
            if permissions.canChangeLayout {
                ObjectSetting.layout
            }
            
            ObjectSetting.relations
            
            if FeatureFlags.versionHistory, permissions.canShowVersionHistory {
                ObjectSetting.history
            }
        }
    }
}
