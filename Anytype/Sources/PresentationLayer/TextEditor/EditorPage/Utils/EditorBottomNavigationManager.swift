import Foundation
import AnytypeCore

protocol EditorBottomNavigationManagerProtocol: AnyObject {
    func multiselectActive(_ active: Bool)
    func onScroll(bottom: Bool)
    func styleViewActive(_ active: Bool)
}

protocol EditorBottomNavigationManagerOutput: AnyObject {
    func setHomeBottomPanelHidden(_ hidden: Bool)
}

final class EditorBottomNavigationManager: EditorBottomNavigationManagerProtocol {
    
    // MARK: - DI
    
//    private weak var browser: EditorBrowser?
    weak var output: EditorBottomNavigationManagerOutput?
    
    // MARK: - State
    
    private var isMultiselectActive = false
    private var scrollDirectionBottom = false
    private var isStyleViewActive = false
    
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
//            environmentBridge.setHomeBottomPanelHidden(true, animated: animated)
            output?.setHomeBottomPanelHidden(true)
            return
        }
        
        if isStyleViewActive {
//            browser?.setNavigationViewHidden(true, animated: animated)
//            environmentBridge.homeBottomPanelHidden = true
//            environmentBridge.setHomeBottomPanelHidden(true, animated: animated)
            output?.setHomeBottomPanelHidden(true)
            return
        }

        if scrollDirectionBottom {
//            browser?.setNavigationViewHidden(true, animated: animated)
//            environmentBridge.homeBottomPanelHidden = true
//            environmentBridge.setHomeBottomPanelHidden(true, animated: animated)
            output?.setHomeBottomPanelHidden(true)
        } else {
//            browser?.setNavigationViewHidden(false, animated: animated)
//            environmentBridge.homeBottomPanelHidden = false
//            environmentBridge.setHomeBottomPanelHidden(false, animated: animated)
            output?.setHomeBottomPanelHidden(false)
        }
    }
}
