import UIKit
import Social
import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices

enum ShareExtensionError: Error {
    case parseFailure
    case copyFailure
}


class ShareViewController: SLComposeServiceViewController {
    private let typeText = UTType.plainText
    private let typeURL = UTType.url
    private let typeImage = UTType.image
    private let sharedContentManager = SharedContentManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let items = extensionItem.attachments else {
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        storeSharedItems(items: items, extensionItem: extensionItem)
    }
    
    private func storeSharedItems(items: [NSItemProvider], extensionItem: NSExtensionItem) {
        let group = DispatchGroup()
        
        var sharedContent = [SharedContent]()
        
        let resultHandler: ((Result<SharedContent, Error>) -> Void) = { result in
            switch result {
            case .success(let success):
                sharedContent.append(success)
            case .failure:
                break
            }
            
            group.leave()
        }
        
        items.forEach { itemProvider in
            group.enter()
            if itemProvider.hasItemConformingToTypeIdentifier(typeText.identifier) {
                handleText(extensionItem: extensionItem, itemProvider: itemProvider, completion: resultHandler)
            } else if itemProvider.hasItemConformingToTypeIdentifier(typeURL.identifier) {
                handleURL(itemProvider: itemProvider, completion: resultHandler)
            } else if itemProvider.hasItemConformingToTypeIdentifier(typeImage.identifier) {
                handleImage(itemProvider: itemProvider, completion: resultHandler)
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            try? self?.sharedContentManager.saveSharedContent(content: sharedContent)
            
            self?.openMainApp()
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
    
    private func handleText(
        extensionItem: NSExtensionItem,
        itemProvider: NSItemProvider,
        completion: @escaping (Result<SharedContent, Error>) -> Void
    ) {
        if let attributedString =  extensionItem.attributedContentText {
            completion(.success(.text(AttributedString(attributedString))))
            return
        }
        
        itemProvider.loadItem(
            forTypeIdentifier: UTType.text.identifier,
            options: nil
        ) { (item, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(.text(AttributedString(item as? String ?? ""))))
        }
    }
    
    private func handleURL(
        itemProvider: NSItemProvider,
        completion: @escaping (Result<SharedContent, Error>) -> Void
    )  {
        itemProvider.loadItem(
            forTypeIdentifier: typeURL.identifier,
            options: nil
        ) { (item, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let url = item as? NSURL else {
                completion(.failure(ShareExtensionError.parseFailure))
                return
            }
            
            completion(.success(.url(url as URL)))
        }
    }
    
    private func handleImage(
        itemProvider: NSItemProvider,
        completion: @escaping (Result<SharedContent, Error>) -> Void
    )  {
        itemProvider.loadItem(
            forTypeIdentifier: typeImage.identifier,
            options: nil
        ) { (item, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            guard let imageURL = item as? URL else {
                completion(.failure(ShareExtensionError.copyFailure))
                return
            }
            
            guard var containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: TargetsConstants.appGroup
            ) else {
                fatalError()
            }
            containerURL = containerURL
                .appendingPathComponent("Library/Caches")
                .appendingPathComponent(imageURL.lastPathComponent)
            
            do {
                try FileManager.default.copyItem(at: imageURL, to: containerURL)
                completion(.success(.image(containerURL)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    
    private func openMainApp() {
        _ = URLConstants.sharingExtenstionURL.map { openURL($0) }
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
