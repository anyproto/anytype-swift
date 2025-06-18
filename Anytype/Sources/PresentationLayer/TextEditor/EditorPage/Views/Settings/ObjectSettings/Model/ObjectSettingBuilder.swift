import Services
import AnytypeCore

protocol ObjectSettingsBuilderProtocol {
    func build(details: ObjectDetails, permissions: ObjectPermissions) -> [ObjectSetting]
}

final class ObjectSettingsBuilder: ObjectSettingsBuilderProtocol {
    @Injected(\.objectSettingsConflictManager)
    private var conflictManager: any ObjectSettingsPrimitivesConflictManagerProtocol
    
    func build(details: ObjectDetails, permissions: ObjectPermissions) -> [ObjectSetting] {
        .builder {
           
            if permissions.canChangeIcon {
                ObjectSetting.icon
            }
            
            if permissions.canChangeCover {
                ObjectSetting.cover
            }
            
            let isFeatured = details.featuredRelations.contains { $0 == BundledPropertyKey.description.rawValue }
            ObjectSetting.description(isVisible: isFeatured)
            
            if permissions.canShowRelations {
                ObjectSetting.relations
            }
            
            if permissions.canShowVersionHistory {
                ObjectSetting.history
            }
            
            if conflictManager.haveLayoutConflicts(details: details) {
                ObjectSetting.resolveConflict
            }
        }
    }
}

extension Container {
    var objectSettingsBuilder: Factory<any ObjectSettingsBuilderProtocol> {
        self { ObjectSettingsBuilder() }.shared
    }
}
