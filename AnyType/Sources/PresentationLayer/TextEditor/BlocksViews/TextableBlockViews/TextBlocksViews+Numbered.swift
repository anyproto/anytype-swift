//
//  TextBlocksViews+Numbered.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

// MARK: ViewModel
extension TextBlocksViews.Numbered {
    class BlockViewModel: ObservableObject, Identifiable {
        private var block: Block
        fileprivate var style: Style
        @Published var text: String
        init(block: Block) {
            self.block = block
            self.style = .none
            self.text = "Numbered"
        }
        func update(style: Style) -> Self {
            self.style = style
            return self
        }
        var id = UUID()
    }
}

extension TextBlocksViews.Numbered.BlockViewModel: BlockViewRowBuilderProtocol {
    func buildView() -> AnyView {
        AnyView(TextBlocksViews.Numbered.BlockView(viewModel: self))
    }
}

// MARK: Style
extension TextBlocksViews.Numbered {
    enum Style {
        case none
        case number(Int)
        func string() -> String {
            switch self {
            case .none: return ""
            case let .number(value): return "\(value)"
            }
        }
    }
}
// MARK: View
import SwiftUI
extension TextBlocksViews.Numbered {
    struct MarkedViewModifier: ViewModifier {
        fileprivate var style: Style
        func accessoryView() -> some View {
            return Text(self.style.string() + ".")
            // "TextEditor/Style/Bulleted/mark"
        }
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                self.accessoryView()
                content
            }
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        var body: some View {
            TextView(text: self.$viewModel.text).modifier(MarkedViewModifier(style: self.viewModel.style))
        }
    }
}

// MARK: View Previews
extension TextBlocksViews.Numbered {
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
