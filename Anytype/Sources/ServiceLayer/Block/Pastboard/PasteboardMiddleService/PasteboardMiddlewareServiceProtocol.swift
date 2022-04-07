//
//  PasteboardMiddleService.swift
//  Anytype
//
//  Created by Denis Batvinkin on 22.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels

protocol PasteboardMiddlewareServiceProtocol: AnyObject {
    func pasteText(_ text: String, context: PasteboardActionContext)
    func pasteHTML(_ html: String, context: PasteboardActionContext)
    func pasteBlock(_ blocks: [String], context: PasteboardActionContext)
    func pasteFile(localPath: String, name: String, context: PasteboardActionContext)
    func copy(blocksIds: [BlockId], selectedTextRange: NSRange) -> PasteboardCopyResult?
}
