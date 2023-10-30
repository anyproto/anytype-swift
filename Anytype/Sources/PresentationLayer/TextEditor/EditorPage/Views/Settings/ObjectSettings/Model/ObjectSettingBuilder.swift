import Services

final class ObjectSettingBuilder {
    func build(details: ObjectDetails, restrictions: ObjectRestrictions, isReadonly: Bool) -> [ObjectSetting] {
        var settings = defaultSettings(details: details, isReadonly: isReadonly)
        if restrictions.objectRestriction.contains(.layoutchange) {
            settings = settings.filter { $0 != .layout }
        }
        
        return settings
    }
    
    private func defaultSettings(details: ObjectDetails, isReadonly: Bool) -> [ObjectSetting] {
        if isReadonly { return ObjectSetting.readonlyEditingCases }

        switch details.layoutValue {
        case .basic, .profile, .set, .collection, .space, .file, .image:
            return ObjectSetting.allCases
        case .note:
            return [.layout, .relations]
        case .bookmark, .todo:
            return ObjectSetting.allCases.filter { $0 != .icon }
        case .objectType, .unknown, .relation, .relationOption, .dashboard, .relationOptionList, .database,
                .audio, .video, .date, .spaceView:
            return []
        }
    }
}
