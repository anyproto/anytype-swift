//
//  PageBlocksViews+UserActions.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 16.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension PageBlocksViews {
    enum UserAction {
        case emoji(EmojiAction)
    }
}

extension PageBlocksViews.UserAction {
    typealias Model = EmojiPicker.ViewModel
    enum EmojiAction {
        case shouldShowEmojiPicker(Model)
    }
}
