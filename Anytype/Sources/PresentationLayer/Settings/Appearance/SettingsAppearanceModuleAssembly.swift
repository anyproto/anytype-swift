import Foundation
import SwiftUI

protocol SettingsAppearanceModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make() -> UIViewController
}

final class SettingsAppearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - SettingsAppearanceModuleAssemblyProtocol
    
    @MainActor
    func make() -> UIViewController {
        let model = SettingsAppearanceViewModel()
        let view = SettingsAppearanceView(model: model)
        return AnytypePopup(contentView: view, floatingPanelStyle: false)
    }
}
