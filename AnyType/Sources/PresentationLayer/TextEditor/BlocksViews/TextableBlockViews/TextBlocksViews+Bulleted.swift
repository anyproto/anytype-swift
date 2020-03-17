//
//  TextBlocksViews+Bulleted.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI


// MARK: - ViewModel
extension TextBlocksViews.Bulleted {
    class BlockViewModel: TextBlocksViews.Base.BlockViewModel {
        override func makeUIView() -> UIView {
            UIKitView.init().configured(textView: self.getUIKitViewModel().createView())
        }
        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
}

// MARK: - Style
private extension TextBlocksViews.Bulleted {
    enum Style {
        // should be Self and ExpressiblyByStringLiteral?
        static var `default`: String = "⊙"
    }
}

// MARK: - UIView
private extension TextBlocksViews.Bulleted {
    class UIKitView: UIView {
        typealias TopView = TextBlocksViews.Base.TopWithChildUIKitView
        
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
            
            _ = self.topView.configured(leftChild: {
                let view = UILabel()
                view.text = Style.default
                return view
            }())
//                .configured(leftButton: {
//                let button = UIButton.init(type: .system)
//                button.setTitle(Style.default, for: .normal)
//                button.tintColor = .black
//                return button
//            }())
                        
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
    }
}

// MARK: - View
private extension TextBlocksViews.Bulleted {
    struct MarkedViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                Text(Style.default)
                content
            }
        }
    }
    
    struct BlockView: View {
        @ObservedObject var viewModel: BlockViewModel
        var body: some View {
            TextView(text: self.$viewModel.text, delegate: self.viewModel as TextViewUserInteractionProtocol).modifier(MarkedViewModifier())//.modifier(DraggbleView(blockId: viewModel.id))
        }
    }
}
