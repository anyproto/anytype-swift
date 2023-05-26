//
//  PasteboardOperation.swift
//  Anytype
//
//  Created by Denis Batvinkin on 21.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import AnytypeCore
import Foundation

final class PasteboardOperation: AsyncOperation {

    // MARK: - Private variables

    private let completion: (_ pasteResult: PasteboardPasteResult?) -> Void
    private let context: PasteboardActionContext
    private let pasteboardHelper: PasteboardHelper
    private let pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol

    // MARK: - Initializers

    init(pasteboardHelper: PasteboardHelper,
         pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol,
         context: PasteboardActionContext,
         completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void) {
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

            self.performPaste(context: self.context) { pasteResult in
                self.completion(pasteResult)

                self.state = .finished
            }
        }

        state = .executing
    }

    private func performPaste(context: PasteboardActionContext, completion: @escaping (_ result: PasteboardPasteResult?) -> Void) {
        guard pasteboardHelper.hasSlots else { return completion(nil) }
        
        AnytypeAnalytics.instance().logPasteBlock()
        
        // Find first item to paste with follow order anySlots (blocks slots), htmlSlot, textSlot, filesSlots
        // blocks slots
        if let blocksSlots = pasteboardHelper.obtainBlocksSlots() {
            let result = pasteboardMiddlewareService.pasteBlock(blocksSlots, context: context)
            completion(result)
            return
        }

        // html slot
        if let htmlSlot = pasteboardHelper.obtainHTMLSlot() {
            let result = pasteboardMiddlewareService.pasteHTML(htmlSlot, context: context)
            completion(result)
            return
        }

        // text slot
        if let textSlot = pasteboardHelper.obtainTextSlot() {
            let result = pasteboardMiddlewareService.pasteText(textSlot, context: context)
            completion(result)
            return
        }

        // file slot
        let fileQueue = OperationQueue()
        // for paste file we save only last paste result
        var lastPasteResult: PasteboardPasteResult?

        pasteboardHelper.obtainAsFiles()?.forEach { itemProvider in
            let fileOperation = PasteboardFileOperation(
                itemProvider: itemProvider,
                context: context,
                pasteboardMiddlewareService: pasteboardMiddlewareService
            ) { pasteResult in
                lastPasteResult = pasteResult
            }
            fileQueue.addOperation(fileOperation)
        }

        fileQueue.addBarrierBlock {
            completion(lastPasteResult)
        }
    }
}
