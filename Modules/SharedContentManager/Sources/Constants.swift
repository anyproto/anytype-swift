import Foundation
import AnytypeCore

enum SharedUserDefaultsKey {
    static let sharingExtension = "sharing-extension"
}

extension FileManager {
    var groupURL: URL? {
        containerURL(forSecurityApplicationGroupIdentifier: TargetsConstants.appGroup)
    }
}
