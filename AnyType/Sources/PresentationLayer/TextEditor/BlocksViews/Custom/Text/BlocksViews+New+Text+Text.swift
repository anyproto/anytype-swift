//
//  BlocksViews+New+Text+Text.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.New.Text.Text

private extension Logging.Categories {
    static let textBlocksViewsText: Self = "BlocksViews.New.Text.Text"
}

// MARK: - ViewModel
extension Namespace {
    class ViewModel: BlocksViews.New.Text.Base.ViewModel {
        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
}

// MARK: - View
private extension Namespace {
    struct BlockView: View {
        @ObservedObject var viewModel: ViewModel
        var body: some View {
            VStack {
                TextView(text: self.$viewModel.text, delegate: self.viewModel as TextViewUserInteractionProtocol)
                    //.modifier(DraggbleView(blockId: viewModel.id))
            }
        }
    }
}

