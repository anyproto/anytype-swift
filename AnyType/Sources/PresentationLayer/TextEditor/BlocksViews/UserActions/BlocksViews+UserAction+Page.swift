//
//  BlocksViews+UserAction+Page.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 16.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.UserAction

extension Namespace {
    enum Page {}
}

extension Namespace.Page {
    enum UserAction {
        case emoji(EmojiAction)
    }
}

extension Namespace.Page.UserAction {
    typealias Model = EmojiPicker.ViewModel
    enum EmojiAction {
        case shouldShowEmojiPicker(Model)
    }
}
