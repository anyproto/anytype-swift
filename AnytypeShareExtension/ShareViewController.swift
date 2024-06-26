import UIKit
import Social
import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices
import SharedContentManager
import DeepLinks
import AnytypeCore

class ShareViewController: SLComposeServiceViewController {

    private let sharedContentManager = SharingDI.shared.sharedContentManager()
    #if DEBUG
    private let deepLinkParser = DeepLinkDI.shared.parser(isDebug: true)
    #else
    private let deepLinkParser = DeepLinkDI.shared.parser(isDebug: false)
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        _ = openURL(url)
    }
    
    // Courtesy: https://stackoverflow.com/a/44499222/13363449 👇🏾
    // Function must be named exactly like this so a selector can be found by the compiler!
    // Anyway - it's another selector in another instance that would be "performed" instead.
    @objc private func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
