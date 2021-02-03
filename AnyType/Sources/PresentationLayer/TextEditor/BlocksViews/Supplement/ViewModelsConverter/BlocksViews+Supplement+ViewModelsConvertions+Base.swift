//
//  BlocksViews+Supplement+ViewModelsConvertions+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.Supplement.ViewModelsConvertions
fileprivate typealias FileNamespace = BlocksViews.Supplement.ViewModelsConvertions.BaseConverter
fileprivate typealias ViewModels = BlocksViews.New
extension Namespace {
    class BaseConverter {
        fileprivate let document: DocumentModule.Document.BaseDocument
        func convert(_ blocks: [DocumentModule.Document.BaseDocument.ActiveModel]) -> [BlocksViews.New.Base.ViewModel] { [] }
        func convert(_ block: DocumentModule.Document.BaseDocument.ActiveModel) -> BlocksViews.New.Base.ViewModel? { nil }
        
        init(_ document: DocumentModule.Document.BaseDocument) {
            self.document = document
        }
    }
}

extension Namespace {
    /// TODO: Split later into
    class CompoundConverter: BaseConverter {
        override func convert(_ blocks: [DocumentModule.Document.BaseDocument.ActiveModel]) -> [BlocksViews.New.Base.ViewModel] {
            blocks.compactMap(self.convert)
        }
        override func convert(_ block: DocumentModule.Document.BaseDocument.ActiveModel) -> BlocksViews.New.Base.ViewModel? {
            switch block.blockModel.information.content {
            case .smartblock: return nil // we don't care about smartblocks
            case let .text(value):
                switch value.contentType {
                case .text: return ViewModels.Text.Text.ViewModel.init(block)
                default: return ViewModels.Unknown.Label.ViewModel.init(block)
                }
            case let .file(value):
                switch value.contentType {
                case .file: return ViewModels.File.File.ViewModel.init(block)
                case .none: return ViewModels.Unknown.Label.ViewModel.init(block)
                case .image: return ViewModels.File.Image.ViewModel.init(block)
                case .video: return ViewModels.Unknown.Label.ViewModel.init(block)
                }
            case .divider: return ViewModels.Other.Divider.ViewModel.init(block)
            case .bookmark: return ViewModels.Bookmark.Bookmark.ViewModel.init(block)
            case let .link(value):
                let result = ViewModels.Tools.PageLink.ViewModel(block)
                if let details = self.document.getDetails(by: value.targetBlockID) {
                    _ = result.configured(details.wholeDetailsPublisher)
                }
                return result
            case let .layout(value):
                switch value.style {
                case .div: return ViewModels.Other.Divider.ViewModel.init(block)
                default: return nil // we don't care about layout except divider.
                }
            }
        }
    }
}
