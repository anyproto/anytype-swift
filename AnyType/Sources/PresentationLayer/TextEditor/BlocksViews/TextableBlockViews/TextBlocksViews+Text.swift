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
    class BlockViewModel: ObservableObject, Identifiable {
        private var block: Block
        @Published var text: String
        
        init(block: Block) {
            self.block = block
            self.text = "Text"
        }
        
        var id: String {
            return block.id
        }
    }
}


extension TextBlocksViews.Text.BlockViewModel: BlockViewBuilderProtocol {
    func buildView() -> AnyView {
        AnyView(TextBlocksViews.Text.BlockView(viewModel: self))
    }
}


// MARK: - View

extension TextBlocksViews.Text {
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        var body: some View {
            VStack {
                TextView(text: self.$viewModel.text)
                    .modifier(DraggbleView(blockId: viewModel.id))
            }
        }
    }
}


// MARK: - View Previews
extension TextBlocksViews.Text {
    struct BlockView__Previews: PreviewProvider {
        static var previews: some View {
            let textType = BlockType.Text(text: "some text", contentType: .todo)
            let block = Block(id: "1", childrensIDs: [""], type: .text(textType))
            let viewModel = BlockViewModel(block: block)
            let view = BlockView(viewModel: viewModel)
            return view
        }
    }
}
