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
    @State var sizeThatFit: CGSize = .zero {
        didSet {
            print(sizeThatFit)
        }
    }
    
    init(viewModel: TextBlockViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            TextView(text: self.$text, sizeThatFit: self.$sizeThatFit)
                .modifier(BaseView())
                .frame(maxHeight: self.sizeThatFit.height)
        }
    }
}

struct TextBlockView_Previews: PreviewProvider {
    static var previews: some View {
        TextBlockView(viewModel: TextBlockViewModel())
    }
}
