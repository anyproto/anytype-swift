//
//  BlocksViews+New+Text+Numbered.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
// MARK: - ViewModel
extension BlocksViews.New.Text.Numbered {
    class ViewModel: BlocksViews.New.Text.Base.ViewModel {
        fileprivate var style: Style = .none
        func styleString() -> String? { self.style.string() }
        func update(style: Style) -> Self {
            self.style = style
            return self
        }
        override func makeUIView() -> UIView {
            UIKitView.init().configured(textView: self.getUIKitViewModel().createView()).update(style: self.style)
        }
        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
}

// MARK: Style
extension BlocksViews.New.Text.Numbered {
    enum Style {
        case none
        case number(Int)
        func string() -> String {
            switch self {
            case .none: return ""
            case let .number(value): return "\(value)."
            }
        }
    }
}

// MARK: - UIView
private extension BlocksViews.New.Text.Numbered {
    class UIKitView: UIView {
        typealias TopView = BlocksViews.New.Text.Base.TopWithChildUIKitView
        
        // MARK: Views
        // |    topView    | : | leftView | textView |
        // |   leftView    | : |  button  |
        
        var contentView: UIView!
        var topView: TopView!
                
        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
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
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.topView = {
                let view = TopView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
                                    
            self.contentView.addSubview(topView)
            self.addSubview(contentView)
        }
        
        // MARK: Layout
        func addLayout() {
            if let view = self.topView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
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
                
        // MARK: Configured
        func configured(textView: TextView.UIKitTextView?) -> Self {
            _ = self.topView.configured(textView: textView)
            return self
        }
        
        func update(style: Style) -> Self {
            _ = self.topView.configured(leftChild: {
                let label = UILabel()
                label.text = style.string()
                return label
            }())
            return self
        }
    }
}

// MARK: View
private extension BlocksViews.New.Text.Numbered {
    struct MarkedViewModifier: ViewModifier {
        fileprivate var style: Style
        func accessoryView() -> some View {
            return Text(self.style.string() + ".")
            // "TextEditor/Style/Bulleted/mark"
        }
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                self.accessoryView()
                content
            }
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: ViewModel
        var body: some View {
            TextView(text: self.$viewModel.text, delegate: self.viewModel as TextViewUserInteractionProtocol).modifier(MarkedViewModifier(style: self.viewModel.style))
        }
    }
}
