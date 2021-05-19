//
//  TextViewManagingFocus.swift
//  Anytype
//
//  Created by Denis Batvinkin on 17.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels


/// Text view focus.
struct TextViewFocus {
    /// Cursor position in text view.
    var position: BlockFocusPosition?
    /// We should call completion when we are done with set focus.
    var completion: (Bool) -> () = { _ in }
}

/// Protocol declare methods for managing text view focus.
protocol TextViewManagingFocus: AnyObject {
    /// Ask text view resign first responder.
    func shouldResignFirstResponder()
    /// Set focus in text view.
    /// - Parameter focus: Focus position.
    func setFocus(_ focus: TextViewFocus?)
    /// Obtain text view focus position aka cursor.
    func obtainFocusPosition() -> BlockFocusPosition?
}
