//
//  PasteboardMiddleService.swift
//  Anytype
//
//  Created by Denis Batvinkin on 22.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Services
import Foundation

protocol PasteboardMiddlewareServiceProtocol: AnyObject {
    func pasteText(_ text: String, context: PasteboardActionContext) -> PasteboardPasteResult?
    func pasteHTML(_ html: String, context: PasteboardActionContext) -> PasteboardPasteResult?
    func pasteBlock(_ blocks: [String], context: PasteboardActionContext) -> PasteboardPasteResult?
    func pasteFile(localPath: String, name: String, context: PasteboardActionContext) -> PasteboardPasteResult?
    func copy(blocksIds: [BlockId], selectedTextRange: NSRange) -> PasteboardCopyResult?
}
