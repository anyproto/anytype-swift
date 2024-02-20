//
//  PasteboardServiceProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 28.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Services
import Foundation

protocol PasteboardServiceProtocol: AnyObject {
    var hasValidURL: Bool { get }
    func pasteInsideBlock(focusedBlockId: String,
                          range: NSRange,
                          handleLongOperation: @escaping () -> Void,
                          completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void)
    func pasteInSelectedBlocks(selectedBlockIds: [String],
                               handleLongOperation:  @escaping () -> Void,
                               completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void)
    func copy(blocksIds: [String], selectedTextRange: NSRange) async throws
    func cut(blocksIds: [String], selectedTextRange: NSRange) async throws
}
