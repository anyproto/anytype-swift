//
//  TextView+UserAction.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

// MARK: UserActions
extension TextView {
    public enum UserAction {
        case
        blockAction(BlockAction), // Deprecated
        marksAction(MarksAction), // Deprecated
        inputAction(InputAction),
        keyboardAction(KeyboardAction),
        addBlockAction(AddBlockAction),
        showMultiActionMenuAction(ShowMultiActionMenuAction)
    }
}

// MARK: - BlockAction
extension TextView.UserAction {
    // TODO: Wrap actions in existential types to hide internal types.
    typealias BlockAction = TextView.BlockToolbar.UnderlyingAction
}

// MARK: - MarksAction
extension TextView.UserAction {
    // we should eliminate all typealiases at the end.
    //        enum MarksAction {
    //            typealias MarksType = TextView.HighlightedToolbar.UnderlyingAction.MarksType
    //            case changeMark(NSRange, MarksType)
    //        }
    typealias MarksAction = TextView.HighlightedToolbar.UnderlyingAction // it should be what?! I guess it is Action with range, right?!
}

// MARK: - InputAction
extension TextView.UserAction {
    // Actions with text
    enum InputAction {
        case changeText(NSAttributedString)
    }
}

// MARK: - KeyboardAction
extension TextView.UserAction {
    // Actions with input custom keys
    enum KeyboardAction {
        /// Press some `Key`
        case pressKey(Key)

        static func convert(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Self? {
            return Key.convert(textView, shouldChangeTextIn: range, replacementText: text).flatMap{.pressKey($0)}
        }

        enum Key {
            // TODO:
            // Implement solution with shared `NSAttributedString`.
            // Now we have to create strings on each user key pressing.
            //
            // Possible Solution
            //
            // struct Payload {
            //   var string: String (?)
            //   var left: Substring?
            //   var right: Substring?
            // }

            /// press enter when content is empty (length == 0)
            case enterOnEmptyContent(String?)
            /// press enter when cursor inside the content (content not empty and cursor not at the end)
            case enterInsideContent(String?, String?)
            /// press enter  when cursor at the end of the content
            case enterAtTheEndOfContent
            /// press delete with content (length > 0)
            case deleteWithPayload(String?)
            /// press delete when content is empty (length == 0)
            case deleteOnEmptyContent

            static func convert(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Self? {
                // We should also keep values to the right of the Cursor.
                // So, enter key should have minimum one value as String on the right as Optional<String>
                
                switch (textView.text, range, text) {
                // Easy - our range is equal to .zero and we press "\n" -> we press enter at beginning.
                case (_, .init(location: 0, length: 0), "\n"): return .enterOnEmptyContent(textView.text)

                // Next - our text?.count == at.location + at.length and we press enter.
                // Press enter at the end.
                case let (text, at, "\n") where text?.count == at.location + at.length: return .enterAtTheEndOfContent

                // Here - Compex stuff.
                // We replace characters in string. // Possible Optimization: find index of "\n" insertion.
                // Next, we split this string by "\n".
                // And after that we create payload with left and right parts of the string.
                //
                // In this case we press enter somewhere in the middle of the text.
                // We would like to keep left and right parts of the string in payload.
                // However, we would like to omit right part of the string in text.
                // So, we cut text to the right of "\n".
                // But, not here.
                case let (text, at, "\n"):
                    guard let text = text, let theRange = Range(at, in: text) else { return nil }
                    let separated = text.replacingCharacters(in: theRange, with: "\n").split(separator: "\n")
                    let (left, right) = (separated.first.flatMap(String.init), separated.last.flatMap(String.init))
                    return .enterInsideContent(left, right)

                // Text is empty and range is equal .zero and we press backspace.
                // That means, that our string is empty and we press delete on textView with empty text.
                case ("", .init(location: 0,length: 0), ""): return .deleteOnEmptyContent

                // Next - our text is _not_ empty and range is equal .zero and we press backspace.
                // That means, that our string is not empty and we press delete at the beginning of the string of text view.
                case let (text, .init(location: 0, length: 0), ""): return .deleteWithPayload(text)
                default: return nil
                }
            }
        }
    }
}

// MARK: - AddBlockAction
extension TextView.UserAction {
    enum AddBlockAction {
        case addBlock
    }
}

// MARK: - ShowMultiActionMenu
extension TextView.UserAction {
    enum ShowMultiActionMenuAction {
        case showMultiActionMenu
    }
}

