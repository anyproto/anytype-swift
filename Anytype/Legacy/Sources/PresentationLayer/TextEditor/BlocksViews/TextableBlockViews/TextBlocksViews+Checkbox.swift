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

// MARK: - ViewModel
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
            UIKitView.init(textView: self.getUIKitViewModel().createView())
        }
    }
}

// MARK: - ViewModel / Update view
private extension TextBlocksViews.Checkbox.BlockViewModel {
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

// MARK: - Style
private extension TextBlocksViews.Checkbox {
    enum Style {
        case unchecked
        case checked
        func imageResource() -> String {
            switch self {
            case .unchecked: return "TextEditor/Style/Checkbox/unchecked"
            case .checked: return "TextEditor/Style/Checkbox/checked"
            }
        }
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

// MARK: - UIView
private extension TextBlocksViews.Checkbox {
    class UIKitView: UIView {
        // TODO: Refactor
        // OR
        // We could do it on toggle level or on block parsing level?
        struct Layout {
            var containedViewInset = 8
            var indentationWidth = 8
            var boundaryWidth = 2
        }
        
        var layout: Layout = .init()
    
        // MARK: Accessors
        @Published var checked: Bool = false
        
        // MARK: Actions
        @objc func buttonDidPressed(sender: UIButton) {
            self.checked.toggle()
            sender.isSelected = self.checked
        }
        
        // MARK: Views
        // |    contentView    | : | leftView | textView |
        
        var contentView: UIView!
        var leftView: UIView!
        var textView: UIView!
        
        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        init(textView: TextView.UIKitTextView) {
            super.init(frame: .zero)
            self.textView = textView
            self.setup()
        }
        
        // MARK: Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        // MARK: UI Elements
        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.leftView = {
                let view = UIButton()
                view.addTarget(self, action: #selector(buttonDidPressed(sender:)), for: .touchUpInside)
                view.setImage(.init(imageLiteralResourceName: Style.unchecked.imageResource()), for: .normal)
                view.setImage(.init(imageLiteralResourceName: Style.checked.imageResource()), for: .selected)
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
                             
            self.contentView.addSubview(leftView)
            self.contentView.addSubview(textView)
            self.addSubview(contentView)
        }
        
        // MARK: Layout
        func addLayout() {
            if let view = self.leftView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor),
                    view.widthAnchor.constraint(equalToConstant: view.intrinsicContentSize.width)
                ])
            }
            if let view = self.textView, let superview = view.superview, let leftView = self.leftView {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: CGFloat(self.layout.containedViewInset)),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            if let view = self.contentView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
        
        // MARK: Update / (Could be placed in `layoutSubviews()`)
        func updateView() {
            // toggle animation also
        }
    }
}

// MARK: - View
private extension TextBlocksViews.Checkbox {
    
    struct MarkedViewModifier: ViewModifier {
        func image(checked: Bool) -> String {
            (checked ? Style.checked : Style.unchecked).imageResource()
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
