//
//  TextBlockViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 08.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

/// Textable block view
class TextBlockViewModel: ObservableObject, BlockViewRowBuilderProtocol {
    private var block: Block
    @Published var text: String = ""
    
    required init(block: Block) {
        self.block = block
    }
}

extension TextBlockViewModel: Identifiable {
    
    var id: UUID {
        return UUID()
    }
    
    func buildView() -> AnyView {
       AnyView(TextBlockView(viewModel: self))
    }
}
