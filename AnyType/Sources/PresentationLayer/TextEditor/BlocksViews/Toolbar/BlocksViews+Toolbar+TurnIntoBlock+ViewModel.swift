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
            _ = viewModel.nestedCategories.page([])
            _ = viewModel.nestedCategories.media([])
            _ = viewModel.nestedCategories.tool([])
            _ = viewModel.nestedCategories.other([])
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
