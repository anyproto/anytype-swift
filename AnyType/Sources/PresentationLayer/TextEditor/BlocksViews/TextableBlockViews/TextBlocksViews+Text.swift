//
//  TextBlocksViews+Text.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

// MARK: ViewModel
extension TextBlocksViews.Text {
    class BlockViewModel: ObservableObject, Identifiable {
        private var block: Block
        @Published var text: String
        init(block: Block) {
            self.block = block
            self.text = "1234567"
        }
        var id = UUID()
    }
}

extension TextBlocksViews.Text.BlockViewModel: BlockViewRowBuilderProtocol {
    func buildView() -> AnyView {
        AnyView(TextBlocksViews.Text.BlockView(viewModel: self))
    }
}

// MARK: View
import SwiftUI
extension TextBlocksViews.Text {
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        var body: some View {
            VStack {
                TextView(text: self.$viewModel.text)
            }
        }
    }
}

// MARK: View Previews
extension TextBlocksViews.Text {
    struct BlockView__Previews: PreviewProvider {
        static var previews: some View {
            let textType = BlockType.Text(text: "some text", contentType: .todo)
            let block = Block(id: "1", parentId: "", type: .text(textType))
            let viewModel = BlockViewModel(block: block)
            let view = BlockView(viewModel: viewModel)
            return view
        }
    }
}
