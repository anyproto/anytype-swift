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
            
            let isFeatured = details.featuredRelations.contains { $0 == BundledRelationKey.description.rawValue }
            ObjectSetting.description(isVisible: isFeatured)
            
            ObjectSetting.relations
            
            if permissions.canShowVersionHistory {
                ObjectSetting.history
            }
        }
    }
}
