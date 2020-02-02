//
//  TextBlocksViews+Bulleted.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI


// MARK: - ViewModel
extension TextBlocksViews.Bulleted {
    class BlockViewModel: TextBlocksViews.Base.BlockViewModel {
        override func buildView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
}

// MARK: - View
extension TextBlocksViews.Bulleted {
    struct MarkedViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                Text("⊙")
                content
            }
        }
    }
    
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        var body: some View {
            TextView(text: self.$viewModel.text).modifier(MarkedViewModifier()).modifier(DraggbleView(blockId: viewModel.id))
        }
    }
}

// MARK: - View Previews
extension TextBlocksViews.Bulleted {
    struct BlockView__Previews: PreviewProvider {
        static var previews: some View {
            let textType = BlockType.Text(text: "some text", contentType: .todo)
            let block = Block(id: "1", childrensIDs: [""], type: .text(textType))
            let viewModel = BlockViewModel(block)
            let view = BlockView(viewModel: viewModel)
            return view
        }
    }
}
