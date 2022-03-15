import UIKit
import UniformTypeIdentifiers
import AnytypeCore
import ProtobufMessages

struct PastboardSlots {
    let textSlot: String?
    let htmlSlot: String?
    let anySlot: [Anytype_Model_Block]?

    var onlyTextSlotAvailable: Bool {
        textSlot.isNotNil && htmlSlot.isNil
    }
}

final class PastboardHelper {

    func obtainSlots() -> PastboardSlots{
        let pasteboard = UIPasteboard.general
        var htmlSlot: String? = nil
        var textSlot: String? = nil
        var anySlot: [Anytype_Model_Block]? = nil

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

        return .init(textSlot: textSlot, htmlSlot: htmlSlot, anySlot: anySlot)
    }

    func copy(slots: PastboardSlots) {
        let pasteboard = UIPasteboard.general

        if let textSlot = slots.textSlot {
            pasteboard.setValue(textSlot, forPasteboardType: UTType.plainText.identifier)
        }

        if let htmlSlot = slots.htmlSlot {
            pasteboard.addItems([[UTType.html.identifier: htmlSlot]])
        }

        if let anySlot = slots.anySlot {
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
