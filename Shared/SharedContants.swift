import Foundation

enum URLConstants {
    static let urlScheme = "com.anytype://"
    
    static let createObjectURL = URL(string: urlScheme + "create-object")
    static let sharingExtenstionURL = URL(string: urlScheme + "sharing-extension")
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
