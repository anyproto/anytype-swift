//
//  TextBlockView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct TextBlockView: View {
    private var viewModel: TextBlockViewModel?
    
//    @State var text: String = ""
//    @State var sizeThatFit: CGSize = CGSize(width: 0.0, height: 31.0)
//    @Binding var showBottomInsertLine: Bool
    
    init(viewModel: TextBlockViewModel/*, showBottomInsertLine: Binding<Bool>*/) {
////        self.viewModel = viewModel
////        self._showBottomInsertLine = showBottomInsertLine
    }
    
    var body: some View {
        VStack {
            Text("1")
//            TextView(text: self.$text, sizeThatFit: self.$sizeThatFit)
                .modifier(BaseView())
//                .frame(minHeight: self.sizeThatFit.height, idealHeight: self.sizeThatFit.height, maxHeight: self.sizeThatFit.height)
//            if showBottomInsertLine {
//                Divider()
//            }
        }
    }
    
}

struct TextBlockView_Previews: PreviewProvider {
    static var previews: some View {
        let textType = BlockType.Text(text: "some text", contentType: .text)
        let block = Block(id: "1", parentId: "", type: .text(textType))
        let textBlockViewModel = TextBlockViewModel(block: block)
//        return TextBlockView(viewModel: textBlockViewModel, showBottomInsertLine: .constant(true))
        return TextBlockView(viewModel: textBlockViewModel)
    }
}
