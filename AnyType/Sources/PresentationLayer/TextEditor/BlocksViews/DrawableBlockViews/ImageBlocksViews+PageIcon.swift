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
    class BlockViewModel: ImageBlocksViews.Base.BlockViewModel {
        // Maybe later we need something different
        @Published var imageSource: UIImage = UIImage(named: "Page/DefaultIcon") ?? .init() // take from asset
        override func makeSwiftUIView() -> AnyView {
            .init(ImageBlocksViews.PageIcon.BlockView(viewModel: self))
        }
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
