//
//  ImageBlocksViews+Image.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
// MARK: ViewModel
extension ImageBlocksViews.Image {
    class BlockViewModel: ObservableObject, Identifiable {
        private var block: Block
        @Published var imageSource: UIImage // Maybe later we need something different
        init(block: Block) {
            self.block = block
            self.imageSource = UIImage(named: "logo-sign-part-mobile") ?? .init() // take from asset
        }
        var id: Block.ID {
            return block.id
        }
    }
}

extension ImageBlocksViews.Image.BlockViewModel: BlockViewBuilderProtocol {
    
    func buildView() -> AnyView {
        AnyView(ImageBlocksViews.Image.BlockView(viewModel: self))
    }
}

// MARK: View
extension ImageBlocksViews.Image {
    struct MarkedViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            HStack {
                Text("⊙")
                content
            }
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        var body: some View {
            Image(uiImage: self.viewModel.imageSource)
        }
    }
}

// MARK: View Previews
extension ImageBlocksViews.Image {
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
