import Foundation
import UIKit
import SafariServices

protocol URLOpenerProtocol {
    func canOpenUrl(_ url: URL) -> Bool
    func openUrl(_ url: URL)
}

final class URLOpener: URLOpenerProtocol {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    // MARK: - URLOpenerProtocol
    
    func canOpenUrl(_ url: URL) -> Bool {
        UIApplication.shared.canOpenURL(url.urlByAddingHttpIfSchemeIsEmpty())
    }
    
    func openUrl(_ url: URL) {
        let url = url.urlByAddingHttpIfSchemeIsEmpty()
        if url.containsHttpProtocol {
            let safariController = SFSafariViewController(url: url)
            viewController?.topPresentedController.present(safariController, animated: true)
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
