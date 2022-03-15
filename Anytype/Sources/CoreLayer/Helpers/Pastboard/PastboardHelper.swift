import UIKit
import UniformTypeIdentifiers
import AnytypeCore
import ProtobufMessages

typealias AnySlots = [Anytype_Model_Block]

struct TextSlots {
    let textSlot: String?
    let htmlSlot: String?

    var onlyTextSlotAvailable: Bool {
        textSlot.isNotNil && htmlSlot.isNil
    }
}

struct PastboardSlots {
    let textSlots: TextSlots
    let anySlots: AnySlots?
    let fileSlots:  [NSItemProvider]?
}

final class PastboardHelper {

    func obtainSlots(completion: @escaping (PastboardSlots) -> Void) {
        DispatchQueue.global().async {
            let pasteboard = UIPasteboard.general
            var htmlSlot: String? = nil
            var textSlot: String? = nil
            var anySlot: [Anytype_Model_Block]? = nil
            var fileSlot = [NSItemProvider]()

            if pasteboard.contains(pasteboardTypes: [UTType.html.identifier], inItemSet: nil) {
                if let pasteboardData = pasteboard.data(
                    forPasteboardType: UTType.html.identifier,
                    inItemSet: nil
                ) {
                    pasteboardData.first.map {
                        htmlSlot = String(data: $0, encoding: .utf8)
                    }
                }
            }

            if pasteboard.contains(pasteboardTypes: [UTType.plainText.identifier], inItemSet: nil) {
                textSlot = pasteboard.value(forPasteboardType: UTType.text.identifier) as? String
            }

            if pasteboard.contains(pasteboardTypes: [UTType.anySlot.identifier], inItemSet: nil) {
                if let pasteboardData = pasteboard.data(
                    forPasteboardType: UTType.anySlot.identifier,
                    inItemSet: nil
                ) {

                    anySlot = pasteboardData.compactMap {
                        if let anyJSONSlot = String(data: $0, encoding: .utf8) {
                            return try? Anytype_Model_Block(jsonString: anyJSONSlot)
                        }
                        return nil
                    }
                }
            }

            if pasteboard.contains(pasteboardTypes: [UTType.item.identifier]) {
                pasteboard.itemProviders.forEach { itemProvider in
                    fileSlot.append(itemProvider)
                }
            }

            DispatchQueue.main.async {
                let textSlots = TextSlots(textSlot: textSlot, htmlSlot: htmlSlot)
                completion(.init(textSlots: textSlots, anySlots: anySlot, fileSlots: fileSlot))
            }
        }
    }

    func copy(slots: PastboardSlots) {
        let pasteboard = UIPasteboard.general

        if let textSlot = slots.textSlots.textSlot {
            pasteboard.setValue(textSlot, forPasteboardType: UTType.plainText.identifier)
        }

        if let htmlSlot = slots.textSlots.htmlSlot {
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
