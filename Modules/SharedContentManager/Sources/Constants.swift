import Foundation
import AnytypeCore

enum SharedUserDefaultsKey {
    static let sharingExtension = "sharing-extension"
}

enum TargetsConstants {
    static let appGroup = "group.io.anytype.app"
}

extension FileManager {
    var groupURL: URL? {
        containerURL(forSecurityApplicationGroupIdentifier: TargetsConstants.appGroup)
    }
}
