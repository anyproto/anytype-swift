//
//  ResponderScrollViewHelper.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 19.07.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class ResponderScrollViewHelper: KeyboardHeightListener {

    private weak var scrollView: UIScrollView?

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView

        super.init()
    }

    func textViewDidBeginEditing(textView: UITextView) {
        guard let window = textView.window, let scrollView = scrollView else {
            return
        }

        guard let position = textView.selectedTextRange?.end else { return }
        let cursorPosition = textView.caretRect(for: position)

        let textViewFrame = textView.convert(cursorPosition, to: window)

        let distance = textViewFrame.maxY - currentKeyboardFrame.minY

        if distance > -Constants.minSpacingAboveKeyboard {
            UIView.animate(withDuration: CATransaction.animationDuration()) { [weak scrollView] in
                scrollView?.contentOffset.y += distance + Constants.minSpacingAboveKeyboard
            }
        }
    }
}

extension ResponderScrollViewHelper {
    private enum Constants {
        static let minSpacingAboveKeyboard: CGFloat = 30
    }
}
