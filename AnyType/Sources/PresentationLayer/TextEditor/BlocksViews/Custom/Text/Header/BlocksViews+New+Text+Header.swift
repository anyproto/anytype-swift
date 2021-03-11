//
//  BlocksViews+New+Text+Header.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - ViewModel
extension BlocksViews.New.Text.Header {
    class ViewModel: BlocksViews.New.Text.Base.ViewModel {
        fileprivate var style: Style = .heading2
        func update(style: Style) -> Self {
            self.style = style
            return self
        }
        
        override func makeUIView() -> UIView {
            UIKitView.init().update(style: self.style).configured(textView: self.getUIKitViewModel().createView())
        }

        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
}

// MARK: - Style
extension BlocksViews.New.Text.Header {
    enum Style {
        case none
        case heading1
        case heading2
        case heading3
        case heading4
        func font() -> Font {
            switch self {
            case .none: return .body
            case .heading1: return .largeTitle
            case .heading2: return .title
            case .heading3: return .headline
            case .heading4: return .subheadline
            }
        }
        func fontStyle() -> UIFont.TextStyle {
            switch self {
                case .none: return .body
                case .heading1: return .largeTitle
                case .heading2: return .title1
                case .heading3: return .title2
                case .heading4: return .title3
            }
        }
        func uiKitFont() -> UIFont {
            return UIFont.preferredFont(forTextStyle: self.fontStyle())
        }
        func fontSize() -> CGFloat {
            switch self {
            case .none: return 0
            default: return self.uiKitFont().pointSize
            }
        }
        func theFont() -> Font {
            switch self {
            case .none: return self.font()
            default: return .system(size: self.fontSize(), weight: self.fontWeight(), design: .default)
            }
        }
        func fontWeight() -> Font.Weight {
            switch self {
            case .none: return .regular
            case .heading1: return .bold
            case .heading2: return .heavy
            case .heading3: return .heavy
            case .heading4: return .heavy
            }
        }
        func foregroundColor() -> UIColor {
            return .black
        }
    }
}


// MARK: - UIView
extension BlocksViews.New.Text.Header {
    class UIKitView: UIView {
        typealias TopView = BlocksViews.New.Text.Base.TopWithChildUIKitView
        
        // MARK: Views
        // |    topView    | : | leftView | textView |
        // |   leftView    | : |  button  |
        
        var contentView: UIView!
        var topView: TopView!
        
        var style: Style = .heading1
                
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
            
            _ = self.topView.configured(leftChild: UIView.empty())
                                    
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
            textView?.textView?.font = self.style.uiKitFont()
            return self
        }
        
        func update(style: Style) -> Self {
            self.style = style
            return self
        }        
    }
}

// MARK: - View
private extension BlocksViews.New.Text.Header {
    struct MarkedViewModifier: ViewModifier {
        fileprivate var style: Style
        func body(content: Content) -> some View {
            content.font(self.style.theFont()).foregroundColor(Color(self.style.foregroundColor()))
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: ViewModel
        var body: some View {
            TextField("Untitled", text: self.$viewModel.text)
                .modifier(MarkedViewModifier(style: self.viewModel.style))
        }
    }
}
