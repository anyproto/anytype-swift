//
//  TextBlocksViews+Callout.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: ViewModel
extension TextBlocksViews.Callout {
    class BlockViewModel: ObservableObject, Identifiable {
        private var block: Block
        @Published var text: String
        @Published var style: Style
        init(block: Block) {
            self.block = block
            self.text = "Callout"
            self.style = .emoji("🥳")
        }
        func update(style: Style) -> Self {
            self.style = style
            return self
        }
       var id: String {
            return block.id
        }
    }
}

extension TextBlocksViews.Callout.BlockViewModel: BlockViewBuilderProtocol {
    func buildView() -> AnyView {
        AnyView(TextBlocksViews.Callout.BlockView(viewModel: self))
    }
}

// MARK: Style
extension TextBlocksViews.Callout {
    enum Style {
        case none
        case emoji(String)
        func imageName() -> String {
            switch self {
            case .none: return ":facetime:"
            case let .emoji(name): return name
            }
        }
    }
}

// MARK: - View

extension TextBlocksViews.Callout {
    
    struct MarkedViewModifier: ViewModifier {
        @Binding var style: Style
        func image() -> AnyView {
            if case let .emoji(value) = self.style {
                return AnyView(Text(value))
            }
            else {
                return AnyView(Image(""))
            }
        }
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                Button(action: {
                    
                }) {
                    self.image()
                }
                content
            }
        }
    }
    
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        var body: some View {
            TextView(text: self.$viewModel.text)
                .modifier(MarkedViewModifier(style: self.$viewModel.style))
        }
    }
}

// MARK: View Previews
extension TextBlocksViews.Callout {
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
