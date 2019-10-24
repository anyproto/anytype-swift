//
//  TextBlockView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct TextBlockView: View {
    private let viewModel: TextBlockViewModel
    
    @State var text: String = ""
    @State var sizeThatFit: CGSize = CGSize(width: 0.0, height: 31.0)
    
    init(viewModel: TextBlockViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            TextView(text: self.$text, sizeThatFit: self.$sizeThatFit)
                .modifier(BaseView())
                .frame(minHeight: self.sizeThatFit.height, idealHeight: self.sizeThatFit.height, maxHeight: self.sizeThatFit.height)
        }
    }
}

struct TextBlockView_Previews: PreviewProvider {
    static var previews: some View {
        let textType = BlockType.Text(text: "some text", contentType: .text)
        let block = Block(id: "1", parentId: "", type: .text(textType))
        let textBlockViewModel = TextBlockViewModel(block: block)
        return TextBlockView(viewModel: textBlockViewModel)
    }
}
