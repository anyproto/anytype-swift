import Foundation

enum URLConstants {
    #if DEBUG
    static let urlScheme = "dev-anytype://"
    #else
    static let urlScheme = "anytype://"
    #endif
        
    static let createObjectURL = URL(string: urlScheme + "create-object")
    static let sharingExtenstionURL = URL(string: urlScheme + "sharing-extension")
    static let spaceSelectionURL = URL(string: urlScheme + "space-selection")
    static let galleryImportURL = URL(string: urlScheme + "main/import")
}

enum TargetsConstants {
    static let appGroup = "group.io.anytype.app"
}

extension FileManager {
    var groupURL: URL? {
        containerURL(forSecurityApplicationGroupIdentifier: TargetsConstants.appGroup)
    }
}

enum SharedUserDefaultsKey {
    static let sharingExtension = "sharing-extension"
}

enum AppLinks {
    static let storeLink = URL(string: "https://apps.apple.com/us/app/anytype-private-notes/id6449487029")
}
