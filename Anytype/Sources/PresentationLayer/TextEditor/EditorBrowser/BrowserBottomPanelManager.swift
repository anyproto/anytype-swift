import Foundation

protocol BrowserBottomPanelManagerProtocol: AnyObject {
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool)
}

final class BrowserBottomPanelManager: BrowserBottomPanelManagerProtocol {
    
    private weak var browser: EditorBrowserController?
    
    init(browser: EditorBrowserController?) {
        self.browser = browser
    }
    
    func setNavigationViewHidden(_ isHidden: Bool, animated: Bool) {
        browser?.setNavigationViewHidden(isHidden, animated: animated)
    }
}
