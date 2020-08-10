//
//  BlocksViews+UserAction+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 16.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.UserAction

extension Namespace {
    enum File {}
}

extension Namespace.File {
    /// It is specific `UserAction` for FileBlocks.
    /// It contains specific cases for each subtype of specific BlocksViews.
    /// In our case we have entries referred to `.image`, `.video` and `.file` blocks.
    ///
    enum UserAction {
        case file(FileAction)
        case image(ImageAction)
    }
}

extension Namespace.File.UserAction {
    enum FileAction {
        typealias Model = CommonViews.Pickers.File.Picker.ViewModel
        case shouldShowFilePicker(Model)
    }
}

extension Namespace.File.UserAction {
    enum ImageAction {
        typealias Model = ImagePickerUIKit.ViewModel
        case shouldShowImagePicker(Model)
    }
}

