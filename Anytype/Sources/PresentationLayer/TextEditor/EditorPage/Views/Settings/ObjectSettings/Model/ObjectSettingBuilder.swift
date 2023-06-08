import BlocksModels

final class ObjectSettingBuilder {
    func build(details: ObjectDetails, restrictions: ObjectRestrictions, isLocked: Bool) -> [ObjectSetting] {
        var settings = defaultSettings(details: details, isLocked: isLocked)
        if restrictions.objectRestriction.contains(.layoutchange) {
            settings = settings.filter { $0 != .layout }
        }
        
        return settings
    }
    
    private func defaultSettings(details: ObjectDetails, isLocked: Bool) -> [ObjectSetting] {
        if isLocked { return ObjectSetting.lockedEditingCases }

        switch details.layoutValue {
        case .basic, .profile, .set, .collection, .space, .file, .image:
            return ObjectSetting.allCases
        case .note:
            return [.layout, .relations]
        case .bookmark, .todo:
            return ObjectSetting.allCases.filter { $0 != .icon }
        case .objectType, .unknown, .relation, .relationOption:
            return []
        }
    }
}
