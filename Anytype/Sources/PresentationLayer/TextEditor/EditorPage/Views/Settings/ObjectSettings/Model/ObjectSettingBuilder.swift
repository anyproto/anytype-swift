import Services
import AnytypeCore

final class ObjectSettingBuilder {
    func build(details: ObjectDetails, permissions: ObjectPermissions) -> [ObjectSetting] {
        .builder {
            ObjectSetting.relations
            
            if permissions.canChangeIcon {
                ObjectSetting.icon
            }
            
            if permissions.canChangeCover {
                ObjectSetting.cover
            }
            
            if FeatureFlags.versionHistory, permissions.canShowVersionHistory {
                ObjectSetting.history
            }
        }
    }
}
