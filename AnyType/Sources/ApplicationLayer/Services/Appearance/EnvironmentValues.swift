import SwiftUI

enum Global {
    enum OurEnvironmentKeys {
        struct AssetsCatalog {}
        struct AppearanceService {}
    }
}

extension Global.OurEnvironmentKeys.AssetsCatalog: EnvironmentKey {
    static var defaultValue = AssetsStorage.Local()
}

extension Global.OurEnvironmentKeys.AppearanceService: EnvironmentKey {
    static var defaultValue: AppearanceService = ServiceLocator.shared.resolve()
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
    var servicesAppearance: AppearanceService {
        get {
            self[Global.OurEnvironmentKeys.AppearanceService.self]
        }
        set {
            self[Global.OurEnvironmentKeys.AppearanceService.self] = newValue
        }
    }
}
