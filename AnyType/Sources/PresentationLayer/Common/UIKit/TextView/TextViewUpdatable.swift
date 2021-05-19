//
//  TextViewUpdatable.swift
//  Anytype
//
//  Created by Denis Batvinkin on 17.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


/// Type of update that applied to text view.
enum TextViewUpdate {
    struct Payload {
        var attributedString: NSAttributedString
        var auxiliary: Auxiliary
    }

    struct Auxiliary {
        var textAlignment: NSTextAlignment
        var blockColor: UIColor?
    }

    case text(String)
    case attributedText(NSAttributedString)
    case payload(Payload)
    case auxiliary(Auxiliary)
}

/// Text view that can update itself content.
protocol TextViewUpdatable: AnyObject {
    /// Apply update to text view.
    /// - Parameter update: Update that applied to text view.
    func apply(update: TextViewUpdate)
}
