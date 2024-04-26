import Services

final class ObjectSettingBuilder {
    func build(details: ObjectDetails, restrictions: ObjectRestrictions, isReadonly: Bool) -> [ObjectSetting] {
        var settings = defaultSettings(details: details, isReadonly: isReadonly)
        
        if restrictions.objectRestriction.contains(.layoutchange) {
            settings = settings.filter { $0 != .layout }
        }
        
        if restrictions.objectRestriction.contains(.details) {
            settings = settings.filter { $0 != .cover && $0 != .icon }
        }
        
        return settings
    }
    
    private func defaultSettings(details: ObjectDetails, isReadonly: Bool) -> [ObjectSetting] {
        if isReadonly { return ObjectSetting.readonlyEditingCases }

        switch details.layoutValue {
        case .basic, .profile, .participant, .set, .collection, .space, .file, .image:
            return ObjectSetting.allCases
        case .note:
            return [.layout, .relations]
        case .bookmark, .todo:
            return ObjectSetting.allCases.filter { $0 != .icon }
        case .objectType, .UNRECOGNIZED, .relation, .relationOption, .dashboard, .relationOptionsList,
                .audio, .video, .pdf, .date, .spaceView:
            return []
        }
    }
}
