import Foundation
import UIKit

@MainActor
final class SettingsAppearanceViewModel: ObservableObject {
    
    // MARK: - Private
    
    private var viewControllerProvider: ViewControllerProviderProtocol
    private weak var output: SettingsAppearanceModuleOutput?
    
    // MARK: - Public
    
    @Published var currentStyle = UserDefaultsConfig.userInterfaceStyle {
        didSet {
            UISelectionFeedbackGenerator().selectionChanged()
            UserDefaultsConfig.userInterfaceStyle = currentStyle
            viewControllerProvider.window?.overrideUserInterfaceStyle = currentStyle
        }
    }
    
    @Published var currentIcon = AppIconManager.shared.currentIcon

    init(viewControllerProvider: ViewControllerProviderProtocol, output: SettingsAppearanceModuleOutput?) {
        self.viewControllerProvider = viewControllerProvider
        self.output = output
    }
    
    func onWallpaperChangeTap() {
        output?.onWallpaperChangeSelected()
    }
    
    func updateIcon(_ icon: AppIcon) {
        AppIconManager.shared.setIcon(icon) { [weak self] error in
            guard let self, !error else { return }
            self.currentIcon = AppIconManager.shared.currentIcon
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
