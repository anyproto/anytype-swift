import SwiftUI

enum Global {
    enum OurEnvironmentKeys {
        struct AssetsCatalog {}
    }
}

extension Global.OurEnvironmentKeys.AssetsCatalog: EnvironmentKey {
    static var defaultValue = AssetsStorage.Local()
}

extension EnvironmentValues {
    var assetsCatalog: AssetsStorage.Local {
        get {
            self[Global.OurEnvironmentKeys.AssetsCatalog.self]
        }
        set {
            self[Global.OurEnvironmentKeys.AssetsCatalog.self] = newValue
        }
    }
}
