import Foundation
import UIKit

@MainActor
final class SettingsAppearanceViewModel: ObservableObject {
    
    // MARK: - Private
    
    private var viewControllerProvider: ViewControllerProviderProtocol
    
    // MARK: - Public
    
    @Published var currentStyle = UserDefaultsConfig.userInterfaceStyle {
        didSet {
            UISelectionFeedbackGenerator().selectionChanged()
            UserDefaultsConfig.userInterfaceStyle = currentStyle
            viewControllerProvider.window?.overrideUserInterfaceStyle = currentStyle
        }
    }
    
    @Published var currentIcon = AppIconManager.shared.currentIcon

    init(viewControllerProvider: ViewControllerProviderProtocol) {
        self.viewControllerProvider = viewControllerProvider
    }
    
    func updateIcon(_ icon: AppIcon) {
        AppIconManager.shared.setIcon(icon) { [weak self] error in
            guard let self, !error else { return }
            self.currentIcon = AppIconManager.shared.currentIcon
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
