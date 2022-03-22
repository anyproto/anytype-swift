//
//  PasteboardHelper.swift
//  Anytype
//
//  Created by Denis Batvinkin on 21.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

final class PasteboardHelper {
    private let pasteboard = UIPasteboard.general

    func obtainBlocksSlots() -> [String]? {
        if pasteboard.contains(pasteboardTypes: [UTType.blockSlot.identifier], inItemSet: nil) {
            if let pasteboardData = pasteboard.values(
                forPasteboardType: UTType.blockSlot.identifier,
                inItemSet: nil
            ) as? [Data] {
                let blockSlots = pasteboardData.compactMap { data in
                    String(data: data, encoding: .utf8)
                }
                if blockSlots.isNotEmpty {
                    return blockSlots
                }
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

    func obtainAsFiles() -> [NSItemProvider]? {
        return pasteboard.itemProviders
    }

    func setItems(textSlot: String?, htmlSlot: String?, blocksSlots: [String]?) {
        var textSlots: [String: Any] = [:]
        var allSlots: [[String: Any]] = [[:]]

        if let textSlot = textSlot {
            textSlots[UTType.plainText.identifier] = textSlot
        }

        if let htmlSlot = htmlSlot {
            textSlots[UTType.plainText.identifier] = htmlSlot
        }

        if let blocksSlots = blocksSlots {
            allSlots = blocksSlots.compactMap { blockSlot in
                [UTType.blockSlot.identifier: blockSlot.data(using: .utf8) ?? blockSlot]
            }
        }
        allSlots.append(textSlots)
        pasteboard.setItems(allSlots)
    }

    var hasValidURL: Bool {
        if pasteboard.hasURLs, let url = pasteboard.url?.absoluteString, url.isValidURL() {
            return true
        }
        return false
    }
}

extension UIPasteboard {
    var hasSlots: Bool {
        UIPasteboard.general.contains(pasteboardTypes: [UTType.html.identifier], inItemSet: nil) ||
        UIPasteboard.general.contains(pasteboardTypes: [UTType.utf8PlainText.identifier])
    }
}
