//
//  TextViewManagingFocus.swift
//  Anytype
//
//  Created by Denis Batvinkin on 17.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import BlocksModels


/// Protocol declare methods for managing text view focus.
protocol TextViewManagingFocus: AnyObject {
    /// Ask text view resign first responder.
    func shouldResignFirstResponder()
    /// Set focus in text view.
    /// - Parameter focus: Focus position.
    func setFocus(_ focus: BlockFocusPosition?)
    /// Obtain text view focus position aka cursor.
    func obtainFocusPosition() -> BlockFocusPosition?
}
