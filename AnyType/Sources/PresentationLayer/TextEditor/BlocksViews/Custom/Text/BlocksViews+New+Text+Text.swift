//
//  BlocksViews+New+Text+Text.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate typealias Namespace = BlocksViews.New.Text

// MARK: - ViewModel
extension Namespace.Text {
    class ViewModel: BlocksViews.New.Text.Base.ViewModel {
        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
}

// MARK: - View
private extension Namespace.Text {
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
