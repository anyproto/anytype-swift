//
//  AccessoryViewProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 12.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit


protocol AccessoryViewSwitcherProtocol {
    func didBeginEditing(textView: UITextView)
    func textWillChange(textView: UITextView, replacementText: String, range: NSRange)
    func textDidChange(textView: UITextView)
    func selectionDidChange(textView: UITextView)
    func didEndEditing(textView: UITextView)
}
