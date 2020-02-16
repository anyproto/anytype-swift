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
        private var textViewModel: TextView.UIKitTextView.ViewModel = .init()
        @Published var checked: Bool = false {
            willSet {
                // BUG: Apple Bug.
                // Subclassing ObservableObject requires explicit invocation of self.objectWillChange.send() in willSet hook in @Published property.
                // Workaround: Explicit invocation
                self.objectWillChange.send()
            }
        }
        
        private var inputSubscriber: AnyCancellable?
        private var outputSubscriber: AnyCancellable?
                
        // MARK: Setup
        func setup() {
            _ = self.textViewModel.configured(self)
            self.setupSubscribers()
        }
        func setupSubscribers() {
            self.outputSubscriber = self.$text.map(TextView.UIKitTextView.ViewModel.Update.text).sink(receiveValue: self.textViewModel.apply(update:))
            self.inputSubscriber = self.textViewModel.onUpdate.sink(receiveValue: self.apply(update:))
        }
        
        // MARK: Subclassing
        override init(_ block: Block) {
            super.init(block)
            self.setup()
//            self.updateViewModel()
        }
        
        override func getID() -> Block.ID {
            super.getID()
        }
        
        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
        
        override func makeUIView() -> UIView {
            self.textViewModel.createView()
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

// MARK: ViewModel / Apply to model.
extension TextBlocksViews.Checkbox.BlockViewModel {
    private func setModelData(text: String) {
        super.text = text
//        self.update { (block) in
//            switch block.type {
//                case let .text(value):
//                    var value = value
//                    value.text = text
//                    block.type = .text(value)
//                default: return
//            }
//        }
    }
    func apply(update: TextView.UIKitTextView.ViewModel.Update) {
        switch update {
        case .unknown: return
        case let .text(value): self.setModelData(text: value)
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
