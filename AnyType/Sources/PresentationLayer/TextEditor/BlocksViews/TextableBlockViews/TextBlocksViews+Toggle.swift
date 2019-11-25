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
        fileprivate var blocks: [BlockViewRowBuilderProtocol] = []
        fileprivate var block: Block
        @Published var text: String
        @Published var toggled: Bool
        init(block: Block) {
            self.block = block
            self.text = "1234567"
            self.toggled = false
        }
        func update(blocks: [BlockViewRowBuilderProtocol]) -> Self {
            self.blocks = blocks
            return self
        }
        var id = UUID()
    }
}

extension TextBlocksViews.Toggle.BlockViewModel: BlockViewRowBuilderProtocol {
    func buildView() -> AnyView {
        AnyView(TextBlocksViews.Toggle.BlockView(viewModel: self))
    }
}

// MARK: View
import SwiftUI
extension TextBlocksViews.Toggle {
    struct MarkedViewModifier: ViewModifier {
        func image(checked: Bool) -> String {
            return checked ? "TextEditor/Style/Checkbox/checked"
            // "TextEditor/Style/Checkbox/checked"
                : "TextEditor/Style/Checkbox/checked"
            // "TextEditor/Style/Checkbox/unchecked"
        }
        @Binding var toggled: Bool
        func body(content: Content) -> some View {
            HStack {
                Button(action: {
                    self.toggled.toggle()
                }) {
                    Image(self.image(checked: self.toggled)).rotationEffect(.init(radians: self.toggled ? Double.pi / 2 : 0))
                }
                content
            }
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        func blocks() -> [BlockViewRowBuilderProtocol] {
            self.viewModel.blocks
        }
        var body2: some View {
            VStack {
                List(self.viewModel.blocks, id: \.id, rowContent: { (element) in
                    Text("Abc")
                    //                    VStack {
                    //                        element.buildView()
                    //                    }
                })
            }.animation(.default)
        }
        var body: some View {
            VStack {
                TextView(text: self.$viewModel.text).modifier(MarkedViewModifier(toggled: self.$viewModel.toggled))
//                List(self.$viewModel.toggled.wrappedValue ? self.viewModel.blocks : [], id: \.id, rowContent: { (element) in
//                    Text("Abc")
////                    VStack {
////                        element.buildView()
////                    }
//                }).animation(.default)
                VStack {
                    if self.viewModel.toggled {
                        //                        ForEach(self.viewModel.blocks, id: \.id) { (element) in
                        //                            element.buildView()
                        //                        }
                        // TODO: add check via geometry reader that offset from left is
                        ForEach(self.viewModel.blocks, id: \.id) { (element) in
                            element.buildView()
                        }
                    }
                }.animation(.easeInOut)
            }
        }
    }
}

// MARK: View Previews
extension TextBlocksViews.Toggle {
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
