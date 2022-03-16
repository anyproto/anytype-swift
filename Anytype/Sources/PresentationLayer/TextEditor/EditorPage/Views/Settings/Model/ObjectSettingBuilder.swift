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
        if isLocked { return ObjectSetting.lockedCases }

        switch details.layout {
        case .basic:
            return ObjectSetting.allCases
        case .profile:
            return ObjectSetting.allCases
        case .todo:
            return ObjectSetting.allCases.filter { $0 != .icon }
        case .note:
            return [.layout, .relations]
        case .set:
            return ObjectSetting.allCases
        }
    }
}
