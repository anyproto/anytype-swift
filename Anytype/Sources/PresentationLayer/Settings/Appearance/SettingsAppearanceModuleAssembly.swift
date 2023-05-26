import Foundation
import SwiftUI

protocol SettingsAppearanceModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(output: SettingsAppearanceModuleOutput?) -> UIViewController
}

final class SettingsAppearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - SettingsAppearanceModuleAssemblyProtocol
    
    @MainActor
    func make(output: SettingsAppearanceModuleOutput?) -> UIViewController {
        let model = SettingsAppearanceViewModel(viewControllerProvider: uiHelpersDI.viewControllerProvider(), output: output)
        let view = SettingsAppearanceView(model: model)
        return AnytypePopup(contentView: view, floatingPanelStyle: false)
    }
}
