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
    class BlockViewModel: TextBlocksViews.Base.BlockViewModel {
        override func buildView() -> AnyView {
            .init(TextBlocksViews.Quote.BlockView(viewModel: self))
        }
    }
}

// MARK: View
import SwiftUI
extension TextBlocksViews.Quote {
    struct GeometryReaderModifier: ViewModifier {
        @Binding var sizeThatFit: CGSize
        func body(content: Content) -> some View {
            HStack {
                Rectangle().frame(width: 3.0, height: self.sizeThatFit.height, alignment: .leading).foregroundColor(.black)
//                Rectangle().frame(minWidth: 3.0, idealWidth: 3.0, maxWidth: 3.0, minHeight: self.sizeThatFit.height, alignment: .leading)
                content
            }
        }
    }
    struct FrameViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            HStack {
                Rectangle().frame(minWidth: 3.0, idealWidth: 3.0, maxWidth: 3.0, minHeight: 3.0, idealHeight: 3.0, maxHeight: nil, alignment: .leading).foregroundColor(.black)//.animation(.default)
                content
            }
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        @State var sizeThatFit: CGSize = CGSize(width: 0.0, height: 31.0)
        var body: some View {
            TextView(text: self.$viewModel.text)
                .modifier(FrameViewModifier())
        }
        func geometryReader(proxy: GeometryProxy) -> Color {
            DispatchQueue.main.async {
                print("this is: \(proxy.size)")
                self.sizeThatFit = proxy.size
            }
            return .clear
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
            let block = Block(id: "1", childrensIDs: [""], type: .text(textType))
            let viewModel = BlockViewModel(block)
            let view = BlockView(viewModel: viewModel)
            return view
        }
    }
}
