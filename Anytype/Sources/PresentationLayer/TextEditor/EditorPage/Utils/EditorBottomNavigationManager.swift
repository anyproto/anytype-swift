import Foundation
import AnytypeCore

protocol EditorBottomNavigationManagerProtocol: AnyObject {
    func multiselectActive(_ active: Bool)
    func onScroll(bottom: Bool)
    func styleViewActive(_ active: Bool)
}

final class EditorBottomNavigationManager: EditorBottomNavigationManagerProtocol {
    
    // MARK: - DI
    
    private weak var browser: EditorBrowser?
    private let environmentBridge: EditorPageViewEnvironmentBridge
    
    // MARK: - State
    
    private var isMultiselectActive = false
    private var scrollDirectionBottom = false
    private var isStyleViewActive = false
    
    init(browser: EditorBrowser?, environmentBridge: EditorPageViewEnvironmentBridge) {
        self.browser = browser
        self.environmentBridge = environmentBridge
    }
    
    // MARK: -
    
    func multiselectActive(_ active: Bool) {
        isMultiselectActive = active
        updateNavigationVisibility(animated: false)
    }

    func onScroll(bottom: Bool) {
        guard !isMultiselectActive, scrollDirectionBottom != bottom else { return }
        scrollDirectionBottom = bottom
        updateNavigationVisibility(animated: true)
    }
    
    func styleViewActive(_ active: Bool) {
        isStyleViewActive = active
        updateNavigationVisibility(animated: false)
    }
    
    private func updateNavigationVisibility(animated: Bool) {
        if isMultiselectActive {
//            browser?.setNavigationViewHidden(true, animated: animated)
            environmentBridge.setHomeBottomPanelHidden(true, animated: animated)
            return
        }
        
        if isStyleViewActive {
//            browser?.setNavigationViewHidden(true, animated: animated)
//            environmentBridge.homeBottomPanelHidden = true
            environmentBridge.setHomeBottomPanelHidden(true, animated: animated)
            return
        }

        if scrollDirectionBottom {
//            browser?.setNavigationViewHidden(true, animated: animated)
//            environmentBridge.homeBottomPanelHidden = true
            environmentBridge.setHomeBottomPanelHidden(true, animated: animated)
        } else {
//            browser?.setNavigationViewHidden(false, animated: animated)
//            environmentBridge.homeBottomPanelHidden = false
            environmentBridge.setHomeBottomPanelHidden(false, animated: animated)
        }
    }
}
