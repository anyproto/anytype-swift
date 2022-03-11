import UIKit
import UniformTypeIdentifiers
import AnytypeCore

struct PastboardSlots {
    let textSlot: String?
    let htmlSlot: String?

    var onlyTextSlotAvailable: Bool {
        textSlot.isNotNil && htmlSlot.isNil
    }
}

final class PastboardHelper {

    func obtainSlots() -> PastboardSlots{
        let pasteboard = UIPasteboard.general
        var htmlSlot: String? = nil
        var textSlot: String? = nil

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

        if pasteboard.contains(pasteboardTypes: [UTType.plainText.identifier]) {
            textSlot = pasteboard.value(forPasteboardType: UTType.text.identifier) as? String
        }

        return .init(textSlot: textSlot, htmlSlot: htmlSlot)
    }
}

extension UIPasteboard {
    var hasSlots: Bool {
        UIPasteboard.general.contains(pasteboardTypes: [UTType.html.identifier], inItemSet: nil) ||
        UIPasteboard.general.contains(pasteboardTypes: [UTType.utf8PlainText.identifier])
    }
}
