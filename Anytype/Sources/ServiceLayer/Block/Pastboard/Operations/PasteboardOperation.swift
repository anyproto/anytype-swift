//
//  PasteboardOperation.swift
//  Anytype
//
//  Created by Denis Batvinkin on 21.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import AnytypeCore

final class PasteboardOperation: AsyncOperation {

    // MARK: - Private variables

    private let completion: (_ isSuccess: Bool) -> Void
    private let context: PasteboardActionContext
    private let pasteboardHelper: PasteboardHelper
    private let pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol

    // MARK: - Initializers

    init(pasteboardHelper: PasteboardHelper,
         pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol,
         context: PasteboardActionContext,
         completion: @escaping (_ isSuccess: Bool) -> Void) {
        self.pasteboardHelper = pasteboardHelper
        self.pasteboardMiddlewareService = pasteboardMiddlewareService
        self.context = context
        self.completion = completion

        super.init()
    }

    override func start() {
        guard !isCancelled else {
            return
        }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            self.performPaste(context: self.context) { isSuccess in
                self.completion(isSuccess)

                self.state = .finished
            }
        }

        state = .executing
    }

    private func performPaste(context: PasteboardActionContext, completion: @escaping (_ isSuccess: Bool) -> Void) {
        guard pasteboardHelper.hasSlots else { return completion(false) }

        // Find first item to paste with follow order anySlots (blocks slots), htmlSlot, textSlot, filesSlots
        // blocks slots
        if let blocksSlots = pasteboardHelper.obtainBlocksSlots() {
            pasteboardMiddlewareService.pasteBlock(blocksSlots, context: context)
            completion(true)
            return
        }

        // html slot
        if let htmlSlot = pasteboardHelper.obtainHTMLSlot() {
            pasteboardMiddlewareService.pasteHTML(htmlSlot, context: context)
            completion(true)
            return
        }

        // text slot
        if let textSlot = pasteboardHelper.obtainTextSlot() {
            pasteboardMiddlewareService.pasteText(textSlot, context: context)
            completion(true)
            return
        }

        // file slot
        let fileQueue = OperationQueue()
        pasteboardHelper.obtainAsFiles()?.forEach { itemProvider in
            let fileOperation = PasteboardFileOperation(itemProvider: itemProvider,
                                                        context: context,
                                                        pasteboardMiddlewareService: pasteboardMiddlewareService)
            fileQueue.addOperation(fileOperation)
        }

        fileQueue.addBarrierBlock {
            completion(true)
        }
    }
}
