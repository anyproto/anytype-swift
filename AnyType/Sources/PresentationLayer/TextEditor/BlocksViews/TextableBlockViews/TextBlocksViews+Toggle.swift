//
//  TextBlocksViews+Toggle.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

// MARK: ViewModel
extension TextBlocksViews.Toggle {
    class BlockViewModel: ObservableObject, Identifiable {
        fileprivate var blocks: [BlockViewBuilderProtocol] = []
        fileprivate var block: Block
        @Published var text: String
        @Published var toggled: Bool
        init(block: Block) {
            self.block = block
            self.text = "Toggle"
            self.toggled = false
        }
        func update(blocks: [BlockViewBuilderProtocol]) -> Self {
            self.blocks = blocks
            return self
        }
        var id: String {
            return block.id
        }
    }
}

extension TextBlocksViews.Toggle.BlockViewModel: BlockViewBuilderProtocol {
    func buildView() -> AnyView {
        AnyView(TextBlocksViews.Toggle.BlockView(viewModel: self))
    }
}

// MARK: View
import SwiftUI
extension TextBlocksViews.Toggle {
    struct MarkedViewModifier: ViewModifier {
        @EnvironmentObject var outerViewNeedsLayout: GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout
        func image(checked: Bool) -> String {
            return checked ? "TextEditor/Style/Checkbox/checked"
                : "TextEditor/Style/Checkbox/checked"
        }
        @Binding var toggled: Bool
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                Button(action: {
                    self.outerViewNeedsLayout.needsLayout = ()
                    self.toggled.toggle()
                }) {
                    Image(self.image(checked: self.toggled)).foregroundColor(.orange).rotationEffect(.init(radians: self.toggled ? Double.pi / 2 : 0))
                }
                content
            }
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        
        func blocks() -> [BlockViewBuilderProtocol] {
            self.viewModel.toggled ? self.viewModel.blocks : []
        }
        var body: some View {
            VStack(spacing: 0.0) {
                TextView(text: self.$viewModel.text).modifier(MarkedViewModifier(toggled: self.$viewModel.toggled))
                VStack(spacing: 0.0) {
                    ForEach(self.blocks(), id: \.id) { (element) in
                        element.buildView()
                    }
                }
            }
        }
    }
}

// MARK: View Previews
extension TextBlocksViews.Toggle {
    struct BlockView__Previews: PreviewProvider {
        static var previews: some View {
            let textType = BlockType.Text(text: "some text", contentType: .todo)
            let block = Block(id: "1", childrensIDs: "", type: .text(textType))
            let viewModel = BlockViewModel(block: block)
            let view = BlockView(viewModel: viewModel)
            return view
        }
    }
}
