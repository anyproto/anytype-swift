//
//  BlocksViews+Toolbar+TurnIntoBlock+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: ViewModelBuilder
extension BlocksViews.Toolbar.TurnIntoBlock {
    enum ViewModelBuilder {
        static func create() -> ViewModel {
            let viewModel: ViewModel = .init()
            viewModel.categories = BlocksTypes.allCases.filter {
                switch $0 {
                case .text: return true
                case .list: return true
                case .page: return true
                case .media: return false
                case .tool: return false
                case .other: return false
                }
            }
            _ = viewModel.configured(title: "Turn Into")
            return viewModel
        }
    }
}

// MARK: ViewModel
extension BlocksViews.Toolbar.TurnIntoBlock {
    typealias BlocksTypes = BlocksViews.Toolbar.BlocksTypes
    typealias Style = BlocksViews.Toolbar.Style
    typealias ViewModel = BlocksViews.Toolbar.AddBlock.ViewModel
}
