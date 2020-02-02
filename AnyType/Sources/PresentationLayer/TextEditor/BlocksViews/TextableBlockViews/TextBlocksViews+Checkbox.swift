//
//  TextBlocksViews+Checkbox.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 18.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: ViewModel
extension TextBlocksViews.Checkbox {
    class BlockViewModel: TextBlocksViews.Base.BlockViewModel {
        @Published var checked: Bool = false {
            willSet {
                // BUG: Apple Bug.
                // Subclassing ObservableObject requires explicit invocation of self.objectWillChange.send() in willSet hook in @Published property.
                // Workaround: Explicit invocation
                self.objectWillChange.send()
            }
        }
        override func buildView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
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

// MARK: View Previews
extension TextBlocksViews.Checkbox {
    struct BlockView__Previews: PreviewProvider {
        static var previews: some View {
            let textType = BlockType.Text(text: "some text", contentType: .todo)
            let block = Block(id: "1", childrensIDs: [""], type: .text(textType))
            let viewModel = BlockViewModel(block)
            let view = BlockView(viewModel: viewModel)
            return view
        }
    }
}
