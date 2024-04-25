import Services

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
        }
    }
}
