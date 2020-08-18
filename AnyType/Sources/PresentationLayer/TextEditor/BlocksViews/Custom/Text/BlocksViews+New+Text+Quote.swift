//
//  BlocksViews+New+Text+Quote.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - ViewModel
extension BlocksViews.New.Text.Quote {
    class ViewModel: BlocksViews.New.Text.Base.ViewModel {
        override func makeUIView() -> UIView {
            UIKitView.init().configured(textView: self.getUIKitViewModel().createView())
        }
        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
    }
}

// MARK: - UIView
private extension BlocksViews.New.Text.Quote.UIKitView {
    enum Style {
        case presentation
        func highlightingColor() -> UIColor {
            return UIColor.init(named: "TextEditor/Colors/DefaultOrange") ?? .black
        }
    }
    struct Layout {
        struct HighlightBorder {
            var width: CGFloat = 2
            var leadingSpace: CGFloat = 10
            var trailingSpace: CGFloat = 15
        }
        var highlightBorder: HighlightBorder = .init()
    }
}
private extension BlocksViews.New.Text.Quote {
    class UIKitView: UIView {
        typealias TopView = BlocksViews.New.Text.Base.TopWithChildUIKitView

        // MARK: Layout
        var style: Style = .presentation
        var layout: Layout = .init()
        
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

            self.topView.onLeftChildWillLayout = { view in
                if let view = view, let superview = view.superview {
                    NSLayoutConstraint.activate([
                        view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: self.layout.highlightBorder.leadingSpace),
                        view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -self.layout.highlightBorder.trailingSpace),
                        view.topAnchor.constraint(equalTo: superview.topAnchor),
                        view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor),
                        view.widthAnchor.constraint(equalToConstant: self.layout.highlightBorder.width)
                    ])
                }
            }

            _ = self.topView.configured(leftChild: {
                let view = UIView()
                view.backgroundColor = self.style.highlightingColor()
                return view
            }())
            
            self.contentView.addSubview(self.topView)
            self.addSubview(self.contentView)
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
private extension BlocksViews.New.Text.Quote {
    struct GeometryReaderModifier: ViewModifier {
        @Binding var sizeThatFit: CGSize
        func body(content: Content) -> some View {
            HStack {
                Rectangle().frame(width: 3.0, height: self.sizeThatFit.height, alignment: .leading).foregroundColor(.black)
//                Rectangle().frame(minWidth: 3.0, idealWidth: 3.0, maxWidth: 3.0, minHeight: self.sizeThatFit.height, alignment: .leading)
                content
            }
        }
    }
    struct FrameViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            HStack {
                Rectangle().frame(minWidth: 3.0, idealWidth: 3.0, maxWidth: 3.0, minHeight: 3.0, idealHeight: 3.0, maxHeight: nil, alignment: .leading).foregroundColor(.black)//.animation(.default)
                content
            }
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: ViewModel
        @State var sizeThatFit: CGSize = CGSize(width: 0.0, height: 31.0)
        var body: some View {
            TextView(text: self.$viewModel.text, delegate: self.viewModel as TextViewUserInteractionProtocol)
                .modifier(FrameViewModifier())
        }
        func geometryReader(proxy: GeometryProxy) -> Color {
            DispatchQueue.main.async {
                print("this is: \(proxy.size)")
                self.sizeThatFit = proxy.size
            }
            return .clear
        }
        func logFunc(object: Any) -> some View {
            print("this is: \(object)")
            return Text("Abc")
        }
    }
}
