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
    class BlockViewModel: TextBlocksViews.Base.BlockViewModel {
        @Published var style: Style = .emoji("🥳") {
            willSet {
                // BUG: Apple Bug.
                // Subclassing ObservableObject requires explicit invocation of self.objectWillChange.send() in willSet hook in @Published property.
                // Workaround: Explicit invocation
                self.objectWillChange.send()
            }
        }
        func update(style: Style) -> Self {
            self.style = style
            return self
        }

        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
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
            let viewModel = BlockViewModel(block)
            let view = BlockView(viewModel: viewModel)
            return view
        }
    }
}
