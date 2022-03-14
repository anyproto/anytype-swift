import BlocksModels

final class ObjectSettingBuilder {
    func build(details: ObjectDetails, restrictions: ObjectRestrictions) -> [ObjectSetting] {
        var settings = defaultSettings(details: details)
        if restrictions.objectRestriction.contains(.layoutchange) {
            settings = settings.filter { $0 != .layout }
        }
        
        return settings
    }
    
    private func defaultSettings(details: ObjectDetails) -> [ObjectSetting] {
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
