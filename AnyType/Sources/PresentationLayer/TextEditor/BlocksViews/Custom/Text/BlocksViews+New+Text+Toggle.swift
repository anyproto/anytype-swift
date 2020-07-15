//
//  BlocksViews+New+Text+Toggle.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

// MARK: - ViewModel
extension BlocksViews.New.Text.Toggle {
    class ViewModel: BlocksViews.New.Text.Base.ViewModel {
        fileprivate var blocks: [BlockViewBuilderProtocol] = []
        @Published var toggled: Bool = false {
            willSet {
                // BUG: Apple Bug.
                // Subclassing ObservableObject requires explicit invocation of self.objectWillChange.send() in willSet hook in @Published property.
                // Workaround: Explicit invocation
                self.objectWillChange.send()
            }
        }
        @Published var insertFirst: Bool = false
        var subscriptions: [AnyCancellable] = []
        
        override init(_ block: BlockModel) {
            super.init(block)
            
            self.$toggled.sink { [weak self] (value) in
                self?.send(textViewAction: .buttonView(.toggle(.toggled(value))))
            }.store(in: &self.subscriptions)
            
            self.$insertFirst.sink { [weak self] (value) in
                self?.send(textViewAction: .buttonView(.toggle(.insertFirst(value))))
            }.store(in: &self.subscriptions)
        }
        
        func update(blocks: [BlockViewBuilderProtocol]) -> Self {
            self.blocks = blocks
            return self
        }
        override func makeSwiftUIView() -> AnyView {
            .init(BlockView(viewModel: self))
        }
        override func makeUIView() -> UIView {
            let view = self.getUIKitViewModel().createView()
            // setTextView
            return UIKitView()
                .configured(blocks: self.blocks)
                .configured(hasChildren: { [weak self] in self?.getBlock().childrenIds().isEmpty == false } )
                .configured(textView: view)
                .configured(toggleButtonStream: self._toggled)
                .configured(inputButtonStream: self._insertFirst)
        }
    }
}

// MARK: - Style
private extension BlocksViews.New.Text.Toggle {
    enum Style {
        case folded
        case unfolded
        func imageResource() -> String {
            switch self {
            case .folded: return "TextEditor/Style/Toggle/folded"
            case .unfolded: return "TextEditor/Style/Toggle/unfolded"
            }
        }
        func foregroundColor() -> UIColor {
            switch self {
            case .folded: return .black
            case .unfolded: return .gray
            }
        }
        static func from(_ flag: Bool) -> Self {
            return flag ? .unfolded : .folded
        }
    }
}

// MARK: - UIView
// It should render whole block itself.
// True?
private extension BlocksViews.New.Text.Toggle {
    class UIKitView: UIView {
        typealias TopView = BlocksViews.New.Text.Base.TopWithChildUIKitView
        // TODO: Refactor
        // OR
        // We could do it on toggle level or on block parsing level?
        struct Layout {
            var containedViewInset = 8
            var indentationWidth = 8
            var boundaryWidth = 2
        }
        
        // MARK: Accessors
        var shouldShowInputButton: Bool { self.isEmpty && self.isUnfolded }
        var shouldShowBlocks: Bool { !self.isEmpty && self.isUnfolded }
        
        var isUnfolded: Bool { self.toggle }
        var isEmpty: Bool { !self.hasChildren() }
                
        var hasChildren: () -> Bool = { false }
        
        var inputButtonsLayoutConstraints: [NSLayoutConstraint] = []
        // MARK: Published
        @Published private var insertFirst: Bool = false {
            didSet {
                self.updateView()
            }
        }
        @Published private var toggle: Bool = false {
            didSet {
                self.updateView()
            }
        }
                
        @Published private var builders: [BlockViewBuilderProtocol] = []
        
        // MARK: Views
        // | > toggleButton |  textField  |
        // |          inputButton         |
        // |   |                          |
        // |   |      stackView           |
        // |   |                          |
        
        // |    topView    | : | > toggle | textField  |
        // |               |   |    inputButton (OR)   |
        // |  bottomView   | : | <-> |   stackView     |
        // |               |   |     |                 |
        
        // |             |   |   topView     |
        // | contentView | : | containerView |
        // |             |   |               |
        
        var contentView: UIView!
        var topView: TopView! // [ > toggleView | textField ]
        
        var bottomView: UIView!
        var inputButton: UIButton!
        var stackView: UIStackView!
        
        // MARK: Actions / UIKit
        @objc func buttonDidPressed(inputButton: UIButton) {
            self.insertFirst.toggle()
        }
        
        @objc func buttonDidPressed(toggleButton: UIButton) {
            self.toggle.toggle()
            toggleButton.isSelected = self.toggle
        }
        
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
            self.updateView()
        }
        
        // MARK: UI Elements
        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
                                    
            let toggleButton: UIButton = {
                let view = UIButton()
                view.setImage(.init(imageLiteralResourceName: Style.folded.imageResource()), for: .normal)
                view.setImage(.init(imageLiteralResourceName: Style.unfolded.imageResource()), for: .selected)
                view.addTarget(self, action: #selector(buttonDidPressed(toggleButton:)), for: .touchUpInside)
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.topView = {
                let view = TopView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            _ = self.topView.configured(leftChild: toggleButton)
                                                
            self.inputButton = {
                let view = UIButton(type: .system)
                view.setTitle("Empty toggle. Type anything…", for: .normal)
                view.addTarget(self, action: #selector(buttonDidPressed(inputButton:)), for: .touchUpInside)
                view.contentHorizontalAlignment = .left
                view.tintColor = .lightGray
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.stackView = {
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .vertical
                view.distribution = .fillEqually
                return view
            }()
            
            self.bottomView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
                             
            self.bottomView.addSubview(inputButton)
            self.bottomView.addSubview(stackView)
            
            self.contentView.addSubview(topView)
            self.contentView.addSubview(bottomView)
            
            self.addSubview(contentView)
        }
        
        // MARK: Layout
        func addLayout() {
            if let view = self.inputButton, let superview = view.superview {
                self.inputButtonsLayoutConstraints = [
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ]
            }
            if let view = self.stackView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            if let view = self.topView, let superview = view.superview {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    //                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
            if let view = self.bottomView, let superview = view.superview, let topView = self.topView {
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: topView.bottomAnchor),
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
            // TODO: Remove StackView later or rethink implementation.
            self.stackView.isHidden = true
            
            let shouldShowInputButton = self.shouldShowInputButton
            let fromAlpha = CGFloat(self.shouldShowInputButton ? 0.0 : 1.0)
            let toAlpha = CGFloat(self.shouldShowInputButton ? 1.0 : 0.0)
            [self.inputButtonsLayoutConstraints].forEach(shouldShowInputButton ? NSLayoutConstraint.activate(_:) : NSLayoutConstraint.deactivate(_:))
            UIView.animate(withDuration: 0.2) {
                self.inputButton.alpha = toAlpha
                self.layoutIfNeeded()
            }
        }
        
        func updateIfNeeded(_ blocks: [BlockViewBuilderProtocol]) {
            // check that builders are different
            if self.builders.count == blocks.count {
                return
            }
            
            for view in self.stackView.arrangedSubviews {
                view.removeFromSuperview()
            }
            
            for view in self.builders.compactMap({$0.buildUIView()}) {
                self.stackView.addArrangedSubview(view)
            }
        }
        
        // MARK: Configured
        func configured(blocks: [BlockViewBuilderProtocol]) -> Self {
            self.updateIfNeeded(blocks)
            return self
        }
        
        func configured(textView: TextView.UIKitTextView?) -> Self {
            _ = self.topView.configured(textView: textView)
            return self
        }
                
        func configured(hasChildren: @escaping () -> Bool) -> Self {
            self.hasChildren = hasChildren
            return self
        }
        
        func configured(inputButtonStream: Published<Bool>) -> Self {
            self._insertFirst = inputButtonStream
            return self
        }
        
        func configured(toggleButtonStream: Published<Bool>) -> Self {
            self._toggle = toggleButtonStream
            return self
        }
    }
}

// MARK: - View
private extension BlocksViews.New.Text.Toggle {
    struct MarkedViewModifier: ViewModifier {
        @EnvironmentObject var outerViewNeedsLayout: GlobalEnvironment.OurEnvironmentObjects.PageScrollViewLayout
        func image(unfolded: Bool) -> String {
            return Style.from(unfolded).imageResource()
        }
        @Binding var toggled: Bool
        func body(content: Content) -> some View {
            HStack(alignment: .top) {
                Button(action: {
                    self.outerViewNeedsLayout.needsLayout = ()
                    self.toggled.toggle()
                }) {
                    Image(self.image(unfolded: self.toggled))//.foregroundColor(.orange).rotationEffect(.init(radians: self.toggled ? Double.pi / 2 : 0))
                }
                content
            }
        }
    }
    struct BlockView: View {
        @ObservedObject var viewModel: ViewModel
        
        func blocks() -> [BlockViewBuilderProtocol] {
            self.viewModel.toggled ? self.viewModel.blocks : []
        }
        var body: some View {
            VStack(spacing: 0.0) {
                TextView(text: self.$viewModel.text).modifier(MarkedViewModifier(toggled: self.$viewModel.toggled))
                VStack(spacing: 0.0) {
                    ForEach(self.blocks(), id: \.blockId) { (element) in
                        element.buildView()
                    }
                }
            }
        }
    }
}
