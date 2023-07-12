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
    func pasteText(_ text: String, context: PasteboardActionContext) async throws -> PasteboardPasteResult
    func pasteHTML(_ html: String, context: PasteboardActionContext) async throws -> PasteboardPasteResult
    func pasteBlock(_ blocks: [String], context: PasteboardActionContext) async throws -> PasteboardPasteResult
    func pasteFiles(_ files: [PasteboardFile], context: PasteboardActionContext) async throws -> PasteboardPasteResult
    func copy(blocksIds: [BlockId], selectedTextRange: NSRange) async throws -> PasteboardCopyResult?
    func cut(blocksIds: [BlockId], selectedTextRange: NSRange) async throws -> PasteboardCopyResult?
}
