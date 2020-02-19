//
//  TextBlocksViews+Text.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI


// MARK: - ViewModel
extension TextBlocksViews.Text {
    class BlockViewModel: TextBlocksViews.Base.BlockViewModel {
        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
}

// MARK: - View
extension TextBlocksViews.Text {
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        var body: some View {
            VStack {
                TextView(text: self.$viewModel.text, delegate: self.viewModel as TextViewUserInteractionProtocol)
                    //.modifier(DraggbleView(blockId: viewModel.id))
            }
        }
    }
}
