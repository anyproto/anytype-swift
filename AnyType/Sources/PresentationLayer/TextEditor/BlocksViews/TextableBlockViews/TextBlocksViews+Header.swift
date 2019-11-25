//
//  TextBlocksViews+Header.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

// MARK: ViewModel
extension TextBlocksViews.Header {
    class BlockViewModel: ObservableObject, Identifiable {
        private var block: Block
        fileprivate var style: Style
        @Published var text: String
        init(block: Block) {
            self.block = block
            self.style = .heading1
            self.text = "1234567"
        }
        func update(style: Style) -> Self {
            self.style = style
            return self
        }
        var id = UUID()
    }
}

extension TextBlocksViews.Header.BlockViewModel: BlockViewRowBuilderProtocol {
    func buildView() -> AnyView {
        AnyView(TextBlocksViews.Header.BlockView(viewModel: self))
    }
}

// MARK: Style
extension TextBlocksViews.Header {
    enum Style {
        case none
        case heading1
        case heading2
        case heading3
        case heading4
        func font() -> Font {
            switch self {
            case .none: return .body
            case .heading1: return .title
            case .heading2: return .title
            case .heading3: return .headline
            case .heading4: return .subheadline
            }
        }
        func fontWeight() -> Font.Weight {
            switch self {
            case .none: return .regular
            case .heading1: return .heavy
            case .heading2: return .heavy
            case .heading3: return .heavy
            case .heading4: return .heavy
            }
        }
        func foregroundColor() -> Color {
            return .gray
        }
    }
}
// MARK: View
import SwiftUI
extension TextBlocksViews.Header {
    struct MarkedViewModifier: ViewModifier {
        fileprivate var style: Style
        func body(content: Content) -> some View {
            content.font(self.style.font()).foregroundColor(self.style.foregroundColor())
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        var body: some View {
            TextField("Input", text: self.$viewModel.text).modifier(MarkedViewModifier(style: self.viewModel.style))
//            TextView(text: self.$viewModel.text, sizeThatFit: self.$sizeThatFit)
        }
    }
}

// MARK: View Previews
extension TextBlocksViews.Header {
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
