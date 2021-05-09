//
//  BlockActionHandler.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


// MARK: - Action Type

extension BlockActionHandler {
    /// Action on style view
    enum ActionType: Hashable {
        case turnIntoTitle
        case turnIntoHeading
        case turnIntoSubheading
        case turnIntoText
        case turnIntoCheckbox
        case turnIntoBulleted
        case turnIntoNumbered
        case turnIntoToggle
        case turnIntoHighlight
        case turnIntoCallout

        case setTextColor(UIColor)
        case setBackgroundColor(UIColor)

        case selecTextColor(UIColor)
        case selecBackgroundColor(UIColor)

        case setBoldStyle
        case setItalicStyle
        case setStrikethroughStyle
        case setKeyboardStyle

        case setLeftAlignment
        case setCenterAlignment
        case setRightAlignment

        case setLink(String)
    }
}

// MARK: - BlockActionHandler

/// Actions from block
class BlockActionHandler {

}
