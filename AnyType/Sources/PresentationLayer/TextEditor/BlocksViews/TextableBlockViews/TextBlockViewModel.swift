//
//  TextBlockViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 08.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

/// Textable block view
class TextBlockViewModel: ObservableObject, Identifiable {
    private var block: Block
    private var textBlock: BlockType.Text
    
    @Published var text: String = block.
    
    required init(block: Block) {
        self.block = block
        self.textBlock = case block.type(let text)
    }
    
    var id: String {
        return block.id
    }
}

extension TextBlockViewModel: BlockViewBuilderProtocol {

    func buildView() -> AnyView {
        AnyView(TextBlockView(viewModel: self))
    }
}
