//
//  TextBlocksViews+Quote.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

// MARK: ViewModel
extension TextBlocksViews.Quote {
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

extension TextBlocksViews.Quote.BlockViewModel: BlockViewRowBuilderProtocol {
    func buildView() -> AnyView {
        AnyView(TextBlocksViews.Quote.BlockView(viewModel: self))
    }
}

// MARK: View
import SwiftUI
extension TextBlocksViews.Quote {
    struct MarkedViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            HStack {
                Rectangle().frame(minWidth: 3.0, idealWidth: 3.0, maxWidth: 3.0, minHeight: 3.0, idealHeight: nil, maxHeight: nil, alignment: .leading).foregroundColor(.black)
                content
            }
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        @State var sizeThatFit: CGSize = CGSize(width: 0.0, height: 31.0)
        var body: some View {
            VStack {
                TextView(text: self.$viewModel.text).modifier(MarkedViewModifier())
            }
        }
        func logFunc(object: Any) -> some View {
            print("this is: \(object)")
            return Text("Abc")
        }
    }
}

// MARK: View Previews
extension TextBlocksViews.Quote {
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
