struct ObjectTypeSearchViewSettings {
    let showPins: Bool
    let showLists: Bool
    let showFiles: Bool
    let incudeNotForCreation: Bool
    let allowPaste: Bool
}

extension ObjectTypeSearchViewSettings {
    static let newObjectCreation = ObjectTypeSearchViewSettings(
        showPins: true,
        showLists: true,
        showFiles: false,
        incudeNotForCreation: false,
        allowPaste: true
    )
    
    static let queryInSet = ObjectTypeSearchViewSettings(
        showPins: false,
        showLists: false,
        showFiles: true,
        incudeNotForCreation: true,
        allowPaste: false
    )
}
