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
            _ = viewModel.nestedCategories.allText()
            _ = viewModel.nestedCategories.allList()
            _ = viewModel.nestedCategories.page([.page])
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
