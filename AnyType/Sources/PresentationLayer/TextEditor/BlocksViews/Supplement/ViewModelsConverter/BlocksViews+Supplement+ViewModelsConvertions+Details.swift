//
//  BlocksViews+Supplement+ViewModelsConvertions+Details.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 05.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import BlocksModels

fileprivate typealias Namespace = BlocksViews.Supplement.ViewModelsConvertions
fileprivate typealias FileNamespace = BlocksViews.Supplement.ViewModelsConvertions.Details
fileprivate typealias ViewModels = BlocksViews.New

extension Namespace {
    enum Details {}
}

extension FileNamespace {
    class BaseConverter {
        fileprivate let document: BaseDocument
        func convert(_ model: BaseDocument.ActiveModel, kind: BaseDocument.DetailsContentKind) -> BlocksViews.New.Page.Base.ViewModel? {
            switch kind {
            case .title: return ViewModels.Page.Title.ViewModel.init(model)
            case .iconEmoji: return ViewModels.Page.IconEmoji.ViewModel.init(model)
            case .iconColor: return nil
            case .iconImage: return nil
            }
        }
        
        init(_ document: BaseDocument) {
            self.document = document
        }
    }
}
