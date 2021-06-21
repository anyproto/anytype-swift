//
//  BlocksViews+Toolbar+TurnIntoBlock+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: ViewModelBuilder
extension BlockToolbarTurnIntoBlock {
    enum ViewModelBuilder {
        static func create() -> ViewModel {
            let viewModel: ViewModel = .init()
            _ = viewModel.nestedCategories.allText()
            _ = viewModel.nestedCategories.allList()
            _ = viewModel.nestedCategories.objects([.page])
            _ = viewModel.nestedCategories.other([.code])
            _ = viewModel.configured(title: "Turn Into")
            return viewModel
        }
    }
}

// MARK: ViewModel
extension BlockToolbarTurnIntoBlock {
    typealias BlocksTypes = BlockToolbarBlocksTypes
    typealias ViewModel = BlockToolbarAddBlockViewModel
}
