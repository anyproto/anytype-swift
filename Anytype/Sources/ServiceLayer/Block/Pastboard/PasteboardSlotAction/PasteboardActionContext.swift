//
//  PasteboardActionContext.swift
//  Anytype
//
//  Created by Denis Batvinkin on 22.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels

enum PasteboardActionContext {
    case focused(BlockId, NSRange)
    case selected([BlockId])

    var focusedBlockId: String {
        switch self {
        case .focused(let blockId, _):
            return blockId
        case .selected(_):
            return ""
        }
    }

    var selectedRange: NSRange {
        switch self {
        case .focused(_, let nSRange):
            return nSRange
        case .selected:
            return NSRange()
        }
    }

    var selectedBlocksIds: [BlockId] {
        switch self {
        case .focused:
            return []
        case .selected(let blocksIds):
            return blocksIds
        }
    }
}
