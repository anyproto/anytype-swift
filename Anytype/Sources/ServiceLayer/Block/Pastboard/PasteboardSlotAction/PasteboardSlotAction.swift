//
//  PasteboardSlotAction.swift
//  Anytype
//
//  Created by Denis Batvinkin on 21.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels

final class PasteboardSlotAction: PasteboardSlotActionProtocol {
    private let service: PasteboardMiddleServiceProtocol
    private let pasteboardHelper: PasteboardHelper?

    init(pasteboardHelper: PasteboardHelper, service: PasteboardMiddleServiceProtocol) {
        self.pasteboardHelper = pasteboardHelper
        self.service = service
    }

    func performPaste(context: PasteboardActionContext, completion: @escaping (_ isSuccess: Bool) -> Void) {
        performAsyncPaste(context: context, completion: completion)
    }

    func performCopy(blocksIds: [BlockId], selectedTextRange: NSRange) {
        if let result = service.copy(blocksIds: blocksIds, selectedTextRange: selectedTextRange) {
            pasteboardHelper?.setItems(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blocksSlots: result.blockSlot)
        }
    }

    var hasValidURL: Bool {
        pasteboardHelper?.hasValidURL ?? false
    }

    private func performAsyncPaste(context: PasteboardActionContext, completion: @escaping (_ isSuccess: Bool) -> Void) {
        // Find first item to paste with follow order anySlots (blocks slots), htmlSlot, textSlot, filesSlots
        // blocks slots
        if let blocksSlots = pasteboardHelper?.obtainBlocksSlots() {
            service.pasteBlock(blocksSlots, context: context)
            completion(true)
            return
        }

        // html slot
        if let htmlSlot = pasteboardHelper?.obtainHTMLSlot() {
            service.pasteHTML(htmlSlot, context: context)
            completion(true)
            return
        }

        // text slot
        if let textSlot = pasteboardHelper?.obtainTextSlot() {
            service.pasteText(textSlot, context: context)
            completion(true)
            return
        }

        // file slot
        let fileQueue = OperationQueue()
        pasteboardHelper?.obtainAsFiles()?.forEach { itemProvider in
            fileQueue.addOperation(PasteboardFileOperation(itemProvider: itemProvider, context: context, service: service))
        }

        fileQueue.addBarrierBlock {
            completion(true)
        }
    }
}
