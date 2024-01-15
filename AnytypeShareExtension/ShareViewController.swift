import UIKit
import Social
import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices
import SharedContentManager

enum ShareExtensionError: Error {
    case parseFailure
    case copyFailure
}

class ShareViewController: SLComposeServiceViewController {
    private let typeText = UTType.plainText
    private let typeURL = UTType.url
    private let typeImage = UTType.image
    private let sharedContentManager = SharingDI.sharedContentManager()
    
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
            try await storeSharedItems(extensionItem: extensionItem)
        }
    }
    
    private func storeSharedItems(extensionItem: NSExtensionItem) async throws {

        let items = extensionItem.attachments ?? []
        var sharedItems = await withTaskGroup(of: SharedContent?.self, returning: [SharedContent].self) { taskGroup in
            items.enumerated().forEach { index, itemProvider in
                if itemProvider.hasItemConformingToTypeIdentifier(typeText.identifier) {
                    taskGroup.addTask { try? await self.handleText(itemProvider: itemProvider) }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeURL.identifier) {
                    taskGroup.addTask { try? await self.handleURL(itemProvider: itemProvider) }
                } else if itemProvider.hasItemConformingToTypeIdentifier(typeImage.identifier) {
                    taskGroup.addTask { try? await self.handleImage(itemProvider: itemProvider) }
                }
            }
            
            return await taskGroup.compactMap { $0 }.reduce(into: [SharedContent]()) { partialResult, content in
                partialResult.append(content)
            }
        }

        try sharedContentManager.saveSharedContent(content: sharedItems)
        openMainApp()
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    private func handleText(itemProvider: NSItemProvider) async throws -> SharedContent {
        let item = try await itemProvider.loadItem(forTypeIdentifier: typeText.identifier)
        guard let text = item as? NSString else { throw ShareExtensionError.parseFailure }
        return .text(AttributedString(text as String))
    }
    
    private func handleURL(itemProvider: NSItemProvider) async throws -> SharedContent {
        let item = try await itemProvider.loadItem(forTypeIdentifier: typeURL.identifier)
        guard let url = item as? NSURL else { throw ShareExtensionError.parseFailure }
        return .url(url as URL)
    }
    
    private func handleImage(itemProvider: NSItemProvider) async throws -> SharedContent {
        let item = try await itemProvider.loadItem(forTypeIdentifier: typeImage.identifier)
        guard let imageURL = item as? NSURL else { throw ShareExtensionError.copyFailure }
        let groupFileUrl = try sharedContentManager.saveFileToGroup(url: imageURL as URL)
        return .image(groupFileUrl)
    }

    private func openMainApp() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            _ = URLConstants.sharingExtenstionURL.map { self.openURL($0) }
        })
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
