//
//  PasteboardSlotActionProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 22.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels

protocol PasteboardSlotActionProtocol {
    func performPaste(context: PasteboardActionContext, completion: @escaping (_ isSuccess: Bool) -> Void)
    func performCopy(blocksIds: [BlockId], selectedTextRange: NSRange)
    var hasValidURL: Bool { get }
}
