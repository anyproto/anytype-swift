import UIKit
import Social
import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices
import SharedContentManager
import DeepLinks
import AnytypeCore
import AppTarget
import LayoutKit

class ShareViewController: UIViewController {

    private let sharedContentManager = SharingDI.shared.sharedContentManager()
    #if DEBUG || RELEASE_NIGHTLY
        private let deepLinkParser = DeepLinkDI.shared.parser(targetType: .debug)
    #elseif RELEASE_ANYTYPE
        private let deepLinkParser = DeepLinkDI.shared.parser(targetType: .releaseAnytype)
    #elseif RELEASE_ANYAPP
        private let deepLinkParser = DeepLinkDI.shared.parser(targetType: .releaseAnyApp)
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activity = UIActivityIndicatorView(style: .large)
        activity.color = .label
        activity.startAnimating()
        view.addSubview(activity) {
            $0.center(in: view)
        }
        
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        Task {
            // Dismiss keyboard fro fix layout in telegram app
            try await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
            view.endEditing(true)
            await storeSharedItems(extensionItem: extensionItem)
        }
    }
    
    private func storeSharedItems(extensionItem: NSExtensionItem) async {
        let safeExtensionItem = SafeSendable(value: extensionItem)
        let sharedItems = await sharedContentManager.importAndSaveItem(item: safeExtensionItem)
        if !sharedItems.items.isEmpty {
            openMainApp()
        }
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    private func openMainApp() {
        guard let url = deepLinkParser.createUrl(deepLink: .showSharingExtension, scheme: .buildSpecific) else { return }
        openURL(url)
    }
    
    private func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url)
                return
            }
            responder = responder?.next
        }
    }
}
