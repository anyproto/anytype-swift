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
    @Published var text: String = ""
    
    required init(block: Block) {
        self.block = block
    }
    
    var id = UUID()
}

extension TextBlockViewModel: BlockViewRowBuilderProtocol {

    func buildView() -> AnyView {
        AnyView(TextBlockView(viewModel: self))
    }
}
