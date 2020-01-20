//
//  ImageBlocksViews+PageIcon.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI


// MARK: ViewModel
extension ImageBlocksViews.PageIcon {
    class BlockViewModel: ObservableObject, Identifiable {
        private var block: Block
        @Published var imageSource: UIImage // Maybe later we need something different
        init(block: Block) {
            self.block = block
            self.imageSource = UIImage(named: "Page/DefaultIcon") ?? .init() // take from asset
        }
        var id: Block.ID {
            return block.id
        }
    }
}

extension ImageBlocksViews.PageIcon.BlockViewModel: BlockViewBuilderProtocol {
    
    func buildView() -> AnyView {
        AnyView(ImageBlocksViews.PageIcon.BlockView(viewModel: self))
    }
}

// MARK: View
extension ImageBlocksViews.PageIcon {
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
            HStack(alignment: .firstTextBaseline) {
                Image(uiImage: self.viewModel.imageSource).resizable().frame(width: 100, height: 100, alignment: .leading)
                Spacer()
            }
        }
    }
}

// MARK: View Previews
extension ImageBlocksViews.PageIcon {
    struct BlockView__Previews: PreviewProvider {
        static var previews: some View {
            let block = Block.mockImage(.pageIcon)
            let viewModel = BlockViewModel(block: block)
            let view = BlockView(viewModel: viewModel)
            return view
        }
    }
}
