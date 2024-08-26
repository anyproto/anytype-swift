import Foundation
import UIKit

@MainActor
final class SettingsAppearanceViewModel: ObservableObject {
    
    // MARK: - Private
    
    private var appInterfaceStyle: AppInterfaceStyle?
    private var userDefaults: any UserDefaultsStorageProtocol
    
    // MARK: - Public
    
    init() {
        let userDefaults = Container.shared.userDefaultsStorage()
        self.userDefaults = userDefaults
        currentStyle = userDefaults.userInterfaceStyle
    }
    
    @Published var currentStyle: UIUserInterfaceStyle {
        didSet {
            UISelectionFeedbackGenerator().selectionChanged()
            userDefaults.userInterfaceStyle = currentStyle
            appInterfaceStyle?(currentStyle)
        }
    }
    
    @Published var currentIcon = AppIconManager.shared.currentIcon
    
    func updateIcon(_ icon: AppIcon) {
        AppIconManager.shared.setIcon(icon) { [weak self] error in
            guard let self, !error else { return }
            self.currentIcon = AppIconManager.shared.currentIcon
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func setAppInterfaceStyle(_ style: AppInterfaceStyle) {
        self.appInterfaceStyle = style
    }
}
