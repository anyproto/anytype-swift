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
    class BlockViewModel: TextBlocksViews.Base.BlockViewModel {
        fileprivate var style: Style = .none
        func update(style: Style) -> Self {
            self.style = style
            return self
        }
        override func buildView() -> AnyView {
            .init(TextBlocksViews.Numbered.BlockView(viewModel: self))
        }
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
            let block = Block(id: "1", childrensIDs: [""], type: .text(textType))
            let viewModel = BlockViewModel(block)
            let view = BlockView(viewModel: viewModel)
            return view
        }
    }
}
