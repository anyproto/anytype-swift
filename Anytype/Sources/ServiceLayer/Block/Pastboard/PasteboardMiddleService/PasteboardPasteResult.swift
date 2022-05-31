//
//  PasteboardPasteResult.swift
//  Anytype
//
//  Created by Denis Batvinkin on 31.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

struct PasteboardPasteResult {
    let caretPosition: Int
    let isSameBlockCaret: Bool
    let blockIds: [BlockId]
}
