struct ObjectTypeSearchViewSettings {
    let showPins: Bool
    let showLists: Bool
    let showFiles: Bool
    let incudeNotForCreation: Bool
    let allowPaste: Bool
}

extension ObjectTypeSearchViewSettings {
    static var newObjectCreation: ObjectTypeSearchViewSettings {
        ObjectTypeSearchViewSettings(
            showPins: true,
            showLists: true,
            showFiles: false,
            incudeNotForCreation: false,
            allowPaste: true
        )
    }
}
