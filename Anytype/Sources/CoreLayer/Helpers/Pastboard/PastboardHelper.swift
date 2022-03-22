import UIKit
import UniformTypeIdentifiers
import AnytypeCore

enum PasteboardSlot {
    case text(String)
    case html(String)
    case anySlots([String])
    case fileSlots([NSItemProvider])
}

final class PasteboardHelper {

    func obtainSlots() -> PasteboardSlot? {
        let pasteboard = UIPasteboard.general
        var fileSlot: [NSItemProvider] = []

        // Find first item to paste with follow order anySlots, htmlSlot, textSlot, fileSlots
        // anySlots
        if pasteboard.contains(pasteboardTypes: [UTType.anySlot.identifier], inItemSet: nil) {
            if let pasteboardData = pasteboard.values(
                forPasteboardType: UTType.anySlot.identifier,
                inItemSet: nil
            ) as? [Data] {
                let anySlots = pasteboardData.compactMap { data in
                    String(data: data, encoding: .utf8)
                }
                    if anySlots.isNotEmpty {
                    return .anySlots(anySlots)
                }
            }
        }

        // htmlSlot
        if pasteboard.contains(pasteboardTypes: [UTType.html.identifier], inItemSet: nil) {
            let data = pasteboard.data(
                forPasteboardType: UTType.html.identifier,
                inItemSet: nil
            )

            if let data = data?.first, let htmlSlot = String(data: data, encoding: .utf8) {
                return .html(htmlSlot)
            }
        }

        // textSlot
        if pasteboard.contains(pasteboardTypes: [UTType.plainText.identifier], inItemSet: nil) {
            let text = pasteboard.value(forPasteboardType: UTType.text.identifier)

            if let text = text as? String {
                return .text(text)
            }
        }
        
        // fileSlots
        pasteboard.itemProviders.forEach { itemProvider in
            fileSlot.append(itemProvider)
        }
        if fileSlot.isNotEmpty {
            return .fileSlots(fileSlot)
        }

        // pasteboard is empty
        return nil
    }

    func copy(slots: [PasteboardSlot]) {
        let pasteboard = UIPasteboard.general
        var textSlots: [String: Any] = [:]
        var allSlots: [[String: Any]] = [[:]]

        slots.forEach { slot in
            switch slot {
            case let .text(text):
                textSlots[UTType.plainText.identifier] = text
            case let .html(html):
                textSlots[UTType.html.identifier] = html
            case let .anySlots(anySlots):
                allSlots = anySlots.compactMap { anySlot in
                    [UTType.anySlot.identifier: anySlot]
                }
            case .fileSlots:
                // Don't have yet
                break
            }
        }
        allSlots.insert(textSlots, at: 0)
        pasteboard.setItems(allSlots)
    }
}

extension UIPasteboard {
    var hasSlots: Bool {
        UIPasteboard.general.contains(pasteboardTypes: [UTType.html.identifier], inItemSet: nil) ||
        UIPasteboard.general.contains(pasteboardTypes: [UTType.utf8PlainText.identifier])
    }
}
