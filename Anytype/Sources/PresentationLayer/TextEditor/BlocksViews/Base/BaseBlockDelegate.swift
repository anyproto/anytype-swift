//
//  BaseBlockDelegate.swift
//  Anytype
//
//  Created by Denis Batvinkin on 14.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels


/// Delegate for base block
protocol BaseBlockDelegate: AnyObject {
    /// Called when block size changed
    func blockSizeChanged()
    /// Block become first responder
    func becomeFirstResponder(for block: BlockModelProtocol)
    /// Tells the delegate when editing of the block begins
    func didBeginEditing()
    /// Tells the delegate when editing of the block will begin
    func willBeginEditing()
}
