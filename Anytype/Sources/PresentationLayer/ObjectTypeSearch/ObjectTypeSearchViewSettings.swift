struct ObjectTypeSearchViewSettings {
    let showPins: Bool
    let showLists: Bool
    let showFiles: Bool
    let showChat: Bool
    let showTemplates: Bool
    let incudeNotForCreation: Bool
    let allowPaste: Bool
    let showPlusButton: Bool
}

extension ObjectTypeSearchViewSettings {
    static let newObjectCreation = ObjectTypeSearchViewSettings(
        showPins: true,
        showLists: true,
        showFiles: false,
        showChat: true,
        showTemplates: false,
        incudeNotForCreation: false,
        allowPaste: true,
        showPlusButton: false
    )
    
    static let queryInSet = ObjectTypeSearchViewSettings(
        showPins: false,
        showLists: true,
        showFiles: true,
        showChat: false,
        showTemplates: true,
        incudeNotForCreation: true,
        allowPaste: false,
        showPlusButton: false
    )
    
    static let setByRelationNewObject = ObjectTypeSearchViewSettings(
        showPins: false,
        showLists: true,
        showFiles: false,
        showChat: false,
        showTemplates: false,
        incudeNotForCreation: false,
        allowPaste: false,
        showPlusButton: false
    )
    
    static let editorChangeType = ObjectTypeSearchViewSettings(
        showPins: false,
        showLists: false,
        showFiles: false,
        showChat: false,
        showTemplates: false,
        incudeNotForCreation: false,
        allowPaste: false,
        showPlusButton: false
    )
    
    static let spaceDefaultObject = ObjectTypeSearchViewSettings(
        showPins: false,
        showLists: false,
        showFiles: false,
        showChat: false,
        showTemplates: false,
        incudeNotForCreation: false,
        allowPaste: false,
        showPlusButton: false
    )
    
    static let library = ObjectTypeSearchViewSettings(
        showPins: false,
        showLists: true,
        showFiles: true,
        showChat: false,
        showTemplates: true,
        incudeNotForCreation: true,
        allowPaste: false,
        showPlusButton: true
    )
}
