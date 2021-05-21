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
    
    /// Actions for file bocks
    ///
    /// - shouldShowFilePicker:  Show picker for files arbitrary types
    /// - shouldShowImagePicker: Show picker to pick content from gallery
    /// - shouldUploadFile: Upload selected file to middle
    /// - shouldSaveFile: Show system view controller to save file to Files app
    enum FileAction {
        
        struct ShouldShowFilePicker {
            typealias Model = CommonViews.Pickers.File.Picker.ViewModel
            var model: Model
        }
        
        struct ShouldShowImagePicker {
            typealias Model = MediaPicker.ViewModel
            var model: Model
        }
        
        struct ShouldUploadFile {
            var filePath: String
        }
        
        struct ShouldSaveFile {
            var fileURL: URL
        }
        
        case shouldShowFilePicker(ShouldShowFilePicker)
        case shouldShowImagePicker(ShouldShowImagePicker)
        case shouldUploadFile(ShouldUploadFile)
        case shouldSaveFile(ShouldSaveFile)
    }
}
