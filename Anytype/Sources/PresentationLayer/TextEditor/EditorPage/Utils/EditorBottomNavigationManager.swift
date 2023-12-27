import Foundation
import AnytypeCore

@MainActor
protocol EditorBottomNavigationManagerProtocol: AnyObject {
    func multiselectActive(_ active: Bool)
    func onScroll(bottom: Bool)
    func styleViewActive(_ active: Bool)
}

@MainActor
protocol EditorBottomNavigationManagerOutput: AnyObject {
    func setHomeBottomPanelHidden(_ hidden: Bool, animated: Bool)
}

@MainActor
final class EditorBottomNavigationManager: EditorBottomNavigationManagerProtocol {
    
    // MARK: - DI
    
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
    
    // TODO: Add animation?
    private func updateNavigationVisibility(animated: Bool) {
        if isMultiselectActive {
            output?.setHomeBottomPanelHidden(true, animated: animated)
            return
        }
        
        if isStyleViewActive {
            output?.setHomeBottomPanelHidden(true, animated: animated)
            return
        }

        if scrollDirectionBottom {
            output?.setHomeBottomPanelHidden(true, animated: animated)
        } else {
            output?.setHomeBottomPanelHidden(false, animated: animated)
        }
    }
}
