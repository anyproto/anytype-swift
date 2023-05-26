import Foundation
import UIKit
import SafariServices

enum URLOpenerPresentationStyle {
    case `default`
    case popover
}

protocol URLOpenerProtocol: AnyObject {
    func canOpenUrl(_ url: URL) -> Bool
    func openUrl(_ url: URL, presentationStyle: URLOpenerPresentationStyle)
}

extension URLOpenerProtocol {
    func openUrl(_ url: URL) {
        openUrl(url, presentationStyle: .default)
    }
}

final class URLOpener: URLOpenerProtocol {
    
    private var navigationContext: NavigationContextProtocol
    
    init(navigationContext: NavigationContextProtocol) {
        self.navigationContext = navigationContext
    }
    
    // MARK: - URLOpenerProtocol
    
    func canOpenUrl(_ url: URL) -> Bool {
        UIApplication.shared.canOpenURL(url.urlByAddingHttpIfSchemeIsEmpty())
    }
    
    func openUrl(_ url: URL, presentationStyle: URLOpenerPresentationStyle) {
        let url = url.urlByAddingHttpIfSchemeIsEmpty()
        if url.containsHttpProtocol {
            let safariController = SFSafariViewController(url: url)
            switch presentationStyle {
            case .default:
                break
            case .popover:
                safariController.modalPresentationStyle = .popover
            }
            
            navigationContext.present(safariController, animated: true)
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
