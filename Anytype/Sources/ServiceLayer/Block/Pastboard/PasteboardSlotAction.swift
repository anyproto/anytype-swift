//
//  PasteboardSlotAction.swift
//  Anytype
//
//  Created by Denis Batvinkin on 21.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels

protocol PasteboardSlotActionProtocol {
    var delegate: PasteboardSlotActionDelegate? { get }

    func performPaste(context: PasteboardActionContext, completion: @escaping (_ isSuccess: Bool) -> Void)
    func performCopy(textSlot: String?, htmlSlot: String?, blockSlot: [String]?)
    var hasValidURL: Bool { get }
}

struct PasteboardActionContext {
    let focusedBlockId: BlockId?
    let range: NSRange?
    let selectedBlocksIds: [BlockId]?
}

protocol PasteboardSlotActionDelegate: AnyObject {
    func pasteText(_ text: String, context: PasteboardActionContext)
    func pasteHTML(_ text: String, context: PasteboardActionContext)
    func pasteBlock(_ blocks: [String], context: PasteboardActionContext)
    func pasteFile(localPath: String, name: String, context: PasteboardActionContext)
}

final class PasteboardSlotAction: PasteboardSlotActionProtocol {
    weak var delegate: PasteboardSlotActionDelegate?
    private let pasteboardHelper: PasteboardHelper?

    init(pasteboardHelper: PasteboardHelper) {
        self.pasteboardHelper = pasteboardHelper
    }

    func performPaste(context: PasteboardActionContext, completion: @escaping (_ isSuccess: Bool) -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.performAsyncPaste(context: context, completion: completion)
        }
    }

    func performCopy(textSlot: String?, htmlSlot: String?, blockSlot: [String]?) {
        pasteboardHelper?.setItems(textSlot: textSlot, htmlSlot: htmlSlot, blocksSlots: blockSlot)
    }

    var hasValidURL: Bool {
        pasteboardHelper?.hasValidURL ?? false
    }

    private func performAsyncPaste(context: PasteboardActionContext, completion: @escaping (_ isSuccess: Bool) -> Void) {
        // Find first item to paste with follow order anySlots (blocks slots), htmlSlot, textSlot, filesSlots
        // blocks slots
        if let blocksSlots = pasteboardHelper?.obtainBlocksSlots() {
            delegate?.pasteBlock(blocksSlots, context: context)
            completion(true)
            return
        }

        // html slot
        if let htmlSlot = pasteboardHelper?.obtainHTMLSlot() {
            delegate?.pasteHTML(htmlSlot, context: context)
            completion(true)
            return
        }

        // text slot
        if let textSlot = pasteboardHelper?.obtainTextSlot() {
            delegate?.pasteText(textSlot, context: context)
            completion(true)
            return
        }

        // file slot
        let fileQueue = OperationQueue()
        pasteboardHelper?.obtainAsFiles()?.forEach { itemProvider in
            fileQueue.addOperation(PasteboardFileOperation(itemProvider: itemProvider, context: context, pasteActionDelegate: delegate))
        }

        fileQueue.addBarrierBlock {
            completion(true)
        }
    }
}
