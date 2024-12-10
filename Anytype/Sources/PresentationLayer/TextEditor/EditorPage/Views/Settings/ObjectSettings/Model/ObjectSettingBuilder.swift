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
            
            if FeatureFlags.primitives {
                let isFeatured = details.featuredRelations.contains { $0 == BundledRelationKey.description.rawValue }
                ObjectSetting.description(isVisible: isFeatured)
            }
            
            if permissions.canChangeLayout && !FeatureFlags.primitives {
                ObjectSetting.layout
            }
            
            ObjectSetting.relations
            
            if FeatureFlags.versionHistory, permissions.canShowVersionHistory {
                ObjectSetting.history
            }
        }
    }
}
