//
//  PasteboardServiceProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 28.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels

protocol PasteboardServiceProtocol {
    var hasValidURL: Bool { get }
    func pasteInsideBlock(focusedBlockId: BlockId, range: NSRange, completion: @escaping () -> Void)
    func pasteInSelectedBlocks(selectedBlockIds: [BlockId], completion: @escaping () -> Void)
    func copy(blocksIds: [BlockId], selectedTextRange: NSRange)
}
