//
//  TextBlocksViews+Checkbox.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 18.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: ViewModel
extension TextBlocksViews.Checkbox {
    class BlockViewModel: TextBlocksViews.Base.BlockViewModel {
        // BUG: Apple Bug.
        // Subclassing ObservableObject requires explicit invocation of self.objectWillChange.send() in willSet hook in @Published property.
        // Workaround: Explicit invocation
        @Published var checked: Bool = false { willSet { self.objectWillChange.send() } }
        
        // MARK: Subclassing        
        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
        
        override func makeUIView() -> UIView {
            self.getUIKitViewModel().createView()
        }
    }
}

// MARK: ViewModel / Update view
extension TextBlocksViews.Checkbox.BlockViewModel {
//    private func updateViewModel() {
//        // BUG: Apple bug.
//        // YOU CANNOT USE self.text= here.
//        // Why? Let me describe a bit.
//        // @Published property is defined in superclass, so, you must access it via super.text=
//        // Ha-ha-ha
//        switch self.getBlock().type {
//        case let .text(value): super.text = value.text
//        default: return
//        }
//    }
}

// MARK: Style
extension TextBlocksViews.Checkbox {
    enum Style {
        case unchecked
        case checked
        func foregroundColor() -> UIColor {
            switch self {
            case .unchecked: return .black
            case .checked: return .gray
            }
        }
        func strikethrough() -> Bool {
            return self == .checked
        }
        static func from(_ flag: Bool) -> Self {
            return flag ? .checked : .unchecked
        }
    }
}

// MARK: - View
extension TextBlocksViews.Checkbox {
    
    struct MarkedViewModifier: ViewModifier {
        func image(checked: Bool) -> String {
            return checked ?
             "TextEditor/Style/Checkbox/checked"
                :
            "TextEditor/Style/Checkbox/unchecked"
        }
        @Binding var checked: Bool
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                Button(action: {
                    self.checked.toggle()
                }) {
                    Image(self.image(checked: self.checked)).foregroundColor(.orange)
                }
                content
            }
        }
    }
    
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        private var style: Style {
            return Style.from(self.viewModel.checked)
        }
        var body: some View {
            TextView(text: self.$viewModel.text, delegate: self.viewModel as TextViewUserInteractionProtocol)
                .foregroundColor(self.style.foregroundColor())
                .strikethrough(self.style.strikethrough())
                .modifier(MarkedViewModifier(checked: self.$viewModel.checked))
        }
    }
}
