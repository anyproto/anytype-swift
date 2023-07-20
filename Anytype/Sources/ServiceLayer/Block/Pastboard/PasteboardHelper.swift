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
    private lazy var pasteboard = UIPasteboard.general

    func obrainString() -> String? {
        return pasteboard.string
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

    var hasValidURL: Bool {
        if let string = pasteboard.string, string.isValidURL(), !pasteboard.hasImages {
            return true
        }
        return false
    }

    var hasSlots: Bool {
        pasteboard.hasSlots
    }
}
