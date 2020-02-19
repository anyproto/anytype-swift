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
    class BlockViewModel: ImageBlocksViews.Base.BlockViewModel {
        // Maybe later we need something different
        @Published var imageSource: UIImage = UIImage(named: "logo-sign-part-mobile") ?? .init() // take from asset
        override func makeSwiftUIView() -> AnyView {
            .init(ImageBlocksViews.Image.BlockView(viewModel: self))
        }
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
