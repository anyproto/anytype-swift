import UIKit
import UniformTypeIdentifiers
import AnytypeCore
import ProtobufMessages

struct PastboardSlots {
    struct FileSlot {
        var name: String
        var url: URL
    }
    let textSlot: String?
    let htmlSlot: String?
    let anySlot: [Anytype_Model_Block]?
    let fileSlot: [FileSlot]?

    var onlyTextSlotAvailable: Bool {
        textSlot.isNotNil && htmlSlot.isNil
    }
}

final class PastboardHelper {

    func obtainSlots(completion: @escaping (PastboardSlots) -> Void) {
        DispatchQueue.global().async {
            let pasteboard = UIPasteboard.general
            var htmlSlot: String? = nil
            var textSlot: String? = nil
            var anySlot: [Anytype_Model_Block]? = nil
            var fileSlot = [PastboardSlots.FileSlot]()

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

            let groupWaitingCompletion = DispatchGroup()
            groupWaitingCompletion.enter()

            let groupWaitingFileSlot = DispatchGroup()

            if pasteboard.contains(pasteboardTypes: [UTType.item.identifier]) {
                pasteboard.itemProviders.forEach { itemProvider in
                    groupWaitingFileSlot.enter()

                    itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) { url, error in
                        if let url = url {
                            fileSlot.append(.init(name: itemProvider.suggestedName ?? "", url: url))
                            groupWaitingFileSlot.leave()
                            groupWaitingCompletion.wait()
                        }
                    }
                }
            }
            groupWaitingFileSlot.wait()

            completion(.init(textSlot: textSlot, htmlSlot: htmlSlot, anySlot: anySlot, fileSlot: fileSlot))
            groupWaitingCompletion.leave()
        }
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
