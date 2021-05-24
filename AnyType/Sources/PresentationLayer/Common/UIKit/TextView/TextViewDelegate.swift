//
//  TextViewDelegate.swift
//  Anytype
//
//  Created by Denis Batvinkin on 17.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//


/// First responder change type.
enum TextViewFirstResponderChange {
    /// Become first responder.
    case become
    /// Resign first responder.
    case resign
}

/// Text view delegate.
protocol TextViewDelegate: AnyObject {
    /// Text view size changed.
    func sizeChanged()

    /// Text view become first responder.
    func changeFirstResponderState(_ change: TextViewFirstResponderChange)
}
