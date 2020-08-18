//
//  BlocksViews+New+Text+Bulleted.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI


// MARK: - ViewModel
extension BlocksViews.New.Text.Bulleted {
    class ViewModel: BlocksViews.New.Text.Base.ViewModel {
        override func makeUIView() -> UIView {
            UIKitView.init().configured(textView: self.getUIKitViewModel().createView())
        }
        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
}

// MARK: - Style
private extension BlocksViews.New.Text.Bulleted {
    enum Style {
        // should be Self and ExpressiblyByStringLiteral?
        case presentation
        var character: String {
            switch self {
            case .presentation: return "·"
            }
        }
        var font: UIFont {
            switch self {
            case .presentation: return .systemFont(ofSize: 20)
            }
        }
        var imageResource: String {
            switch self {
            case .presentation: return "TextEditor/Style/Text/Bulleted/Bullet"
            }
        }
//        static var `default`: String = "·"
    }
}

// MARK: - UIView
private extension BlocksViews.New.Text.Bulleted {
    class UIKitView: UIView {
        typealias TopView = BlocksViews.New.Text.Base.TopWithChildUIKitView
        
        // MARK: Views
        // |    topView    | : | leftView | textView |
        // |   leftView    | : |  button  |
        
        var style: Style = .presentation
        
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
//                let view = UILabel()
//                view.text = self.style.character
//                view.font = self.style.font
//                return view
                let view = UIButton()
                view.setImage(UIImage(named: self.style.imageResource), for: .normal)
                view.isUserInteractionEnabled = false
//                let view = UIImageView()
//                view.image = UIImage(named: self.style.imageResource)
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
private extension BlocksViews.New.Text.Bulleted {
    struct MarkedViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                Text(Style.presentation.character)
                content
            }
        }
    }
    
    struct BlockView: View {
        @ObservedObject var viewModel: ViewModel
        var body: some View {
            TextView(text: self.$viewModel.text, delegate: self.viewModel as TextViewUserInteractionProtocol).modifier(MarkedViewModifier())//.modifier(DraggbleView(blockId: viewModel.id))
        }
    }
}
