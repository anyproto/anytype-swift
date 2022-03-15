import UIKit
import UniformTypeIdentifiers
import AnytypeCore
import ProtobufMessages

typealias AnySlots = [Anytype_Model_Block]

struct PastboardSlots {
    let textSlot: String?
    let htmlSlot: String?
    let anySlots: AnySlots?
    let fileSlots:  [NSItemProvider]?

    var onlyTextSlotAvailable: Bool {
        textSlot.isNotNil && htmlSlot.isNil && anySlots.isNil
    }

    var hasSlots: Bool {
        textSlot.isNotNil || htmlSlot.isNotNil || anySlots.isNotNil || fileSlots.isNotNil
    }
}

enum SlotToPaste {
    case text(String)
    case html(String)
    case anySlots([String])
    case fileSlots([NSItemProvider])
}

final class PastboardHelper {

    func obtainSlots() -> SlotToPaste? {
        let pasteboard = UIPasteboard.general
        var fileSlot: [NSItemProvider]?

        var slotToPaste: SlotToPaste?

        // Dind first item to paste with follow order anySlots, htmlSlot, textSlot, fileSlots
        if pasteboard.contains(pasteboardTypes: [UTType.anySlot.identifier], inItemSet: nil) {
            if let pasteboardData = pasteboard.data(
                forPasteboardType: UTType.anySlot.identifier,
                inItemSet: nil
            ) {

                let anySlots: [String] = pasteboardData.compactMap {
                    if let anyJSONSlot = String(data: $0, encoding: .utf8) {
                        return anyJSONSlot
                    }
                    return nil
                }

                if anySlots.isNotEmpty {
                    return .anySlots(anySlots)
                }
            }
        }

        if pasteboard.contains(pasteboardTypes: [UTType.html.identifier], inItemSet: nil) {
            let data = pasteboard.data(
                forPasteboardType: UTType.html.identifier,
                inItemSet: nil
            )

            if let data = data?.first, let htmlSlot = String(data: data, encoding: .utf8) {
                return .html(htmlSlot)
            }
        }

        if pasteboard.contains(pasteboardTypes: [UTType.plainText.identifier], inItemSet: nil) {
            let text = pasteboard.value(forPasteboardType: UTType.text.identifier)

            if let text = text as? String {
                return .text(text)
            }
        }

        pasteboard.itemProviders.forEach { itemProvider in
            // any slot
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.anySlot.identifier) {
                itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.anySlot.identifier) { data, _ in
                    if let data = data, let htmlSlot = String(data: data, encoding: .utf8) {
                        slotToPaste = .html(htmlSlot)
                        return
                    }
                }
            }

            // html slot
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.html.identifier) {
                itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.html.identifier) { data, _ in
                    if let data = data, let htmlSlot = String(data: data, encoding: .utf8) {
                        slotToPaste = .html(htmlSlot)
                        return
                    }
                }
            }

            // text slot
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.utf8PlainText.identifier) {
                itemProvider.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier, options: nil) { text, _ in
                    if let text = text as? String {
                        slotToPaste = .text(text)
                        return
                    }
                }
            }

            // file slot
            fileSlot?.append(itemProvider)
        }

        fileSlot = [NSItemProvider]()
        pasteboard.itemProviders.forEach { itemProvider in
            fileSlot?.append(itemProvider)
        }

        return slotToPaste
    }

    func copy(slots: PastboardSlots) {
        let pasteboard = UIPasteboard.general

        if let textSlot = slots.textSlot {
            pasteboard.setValue(textSlot, forPasteboardType: UTType.plainText.identifier)
        }

        if let htmlSlot = slots.htmlSlot {
            pasteboard.addItems([[UTType.html.identifier: htmlSlot]])
        }

        if let anySlot = slots.anySlots {
            let anyJSONSlot: [[String: Any]] = anySlot.compactMap { anytypeModelBlock in
                if let jsonString = try? anytypeModelBlock.jsonString() {
                    return [UTType.anySlot.identifier: jsonString]
                }
                return nil
            }
            pasteboard.addItems(anyJSONSlot)
        }
    }
}

extension UIPasteboard {
    var hasSlots: Bool {
        UIPasteboard.general.contains(pasteboardTypes: [UTType.html.identifier], inItemSet: nil) ||
        UIPasteboard.general.contains(pasteboardTypes: [UTType.utf8PlainText.identifier])
    }
}
