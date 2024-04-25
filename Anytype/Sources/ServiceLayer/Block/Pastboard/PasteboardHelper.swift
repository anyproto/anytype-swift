import UIKit
import UniformTypeIdentifiers
import Combine
import AnytypeCore


enum PasteboardContent {
    case string(String)
    case url(AnytypeURL)
    case otherContent
}

protocol PasteboardHelperProtocol {
    var pasteboardContent: PasteboardContent? { get }
    
    func obtainString() -> String?
    func obtainUrl() -> AnytypeURL?
    func obtainBlocksSlots() -> [String]?
    func obtainHTMLSlot() -> String?
    func obtainTextSlot() -> String?
    func obtainAsFiles() -> [NSItemProvider]
    func obtainAllItems() -> [[String: Any]]
    
    func setItems(textSlot: String?, htmlSlot: String?, blocksSlots: [String]?)
    
    var isPasteboardEmpty: Bool { get }
    var numberOfItems: Int { get }
    var hasValidURL: Bool { get }
    var hasStrings: Bool { get }
    var hasSlots: Bool { get }
    
    func startSubscription(onChange: @escaping () -> Void)
    func stopSubscription()
}

final class PasteboardHelper: PasteboardHelperProtocol {
    private lazy var pasteboard = UIPasteboard.general
    
    deinit {
        stopSubscription()
    }
    
    var pasteboardContent: PasteboardContent? {
        guard numberOfItems != 0 else { return nil }
        
        if numberOfItems == 1, hasValidURL, let url = obtainUrl() {
            return .url(url)
        }
        
        if numberOfItems == 1, let string = obtainString() {
            return .string(string)
        }
                    
        return .otherContent
    }

    func obtainString() -> String? {
        return pasteboard.string
    }
    
    func obtainUrl() -> AnytypeURL? {
        obtainString().flatMap(AnytypeURL.init)
    }
    
    func obtainBlocksSlots() -> [String]? {
        if pasteboard.contains(pasteboardTypes: [UTType.blockSlot.identifier], inItemSet: nil) {
            if let pasteboardData = pasteboard.values(
                forPasteboardType: UTType.blockSlot.identifier,
                inItemSet: nil
            ) as? [Data] {
                guard let data = pasteboardData.first else { return nil }

                // https://stackoverflow.com/questions/9164278/storing-nsarray-in-uipasteboard
                let blockSlots = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String]
                return blockSlots
            }
        }
        return nil
    }

    func obtainHTMLSlot() -> String? {
        if pasteboard.contains(pasteboardTypes: [UTType.html.identifier], inItemSet: nil) {
            let data = pasteboard.data(
                forPasteboardType: UTType.html.identifier,
                inItemSet: nil
            )

            if let data = data?.first, let htmlSlot = String(data: data, encoding: .utf8) {
                return htmlSlot
            }
        }
        return nil
    }

    func obtainTextSlot() -> String? {
        if pasteboard.contains(pasteboardTypes: [UTType.plainText.identifier], inItemSet: nil) {
            let text = pasteboard.value(forPasteboardType: UTType.text.identifier)

            if let text = text as? String {
                return text
            }
        }
        return nil
    }

    func obtainAsFiles() -> [NSItemProvider] {
        return pasteboard.itemProviders
    }
    
    func obtainAllItems() -> [[String: Any]] {
        pasteboard.items
    }

    func setItems(textSlot: String?, htmlSlot: String?, blocksSlots: [String]?) {
        var textSlots: [String: Any] = [:]
        var allSlots: [[String: Any]] = []

        if let textSlot = textSlot {
            textSlots[UTType.plainText.identifier] = textSlot
        }

        if let htmlSlot = htmlSlot {
            textSlots[UTType.html.identifier] = htmlSlot
        }

        if let blocksSlots = blocksSlots {
            textSlots[UTType.blockSlot.identifier] = blocksSlots
        }
        allSlots.append(textSlots)
        pasteboard.setItems(allSlots)
    }
    
    var numberOfItems: Int {
        pasteboard.numberOfItems
    }

    var hasValidURL: Bool {
        if let string = pasteboard.string, string.isValidURL(), !pasteboard.hasImages {
            return true
        }
        return false
    }
    
    var hasStrings: Bool {
        pasteboard.hasStrings
    }

    var hasSlots: Bool {
        pasteboard.hasSlots
    }
    
    var isPasteboardEmpty: Bool {
        let items = obtainAllItems()
        
        if items.isEmpty { return true }
        if items.count == 1 && items[0].isEmpty { return true }
        
        return false
    }
    
    // MARK: Subscriptions
    private var subscription: AnyCancellable?
    func startSubscription(onChange: @escaping () -> Void) {
        subscription = NotificationCenter.Publisher(
            center: .default,
            name: UIPasteboard.changedNotification
        )
        .receiveOnMain()
        .sink { _ in
            onChange()
        }
    }
    
    func stopSubscription() {
        NotificationCenter.default.removeObserver(self, name: UIPasteboard.changedNotification, object: nil)
    }
}
