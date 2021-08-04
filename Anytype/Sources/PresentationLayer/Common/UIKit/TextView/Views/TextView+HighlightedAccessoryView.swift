//
//  TextView+HighlightedAccessoryView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

// MARK: - UIKit / UITextView / AccessoryView
extension CustomTextView.HighlightedToolbar {
    class AccessoryView: UIView {
        typealias Style = CustomTextView.Style
        // MARK: Variables
        var style: Style = .default
        var model: ViewModel = .init()
        var userResponse: AnyCancellable?

        // MARK: Updates
        func update(range: NSRange, states: [State]) {

            guard range.length != 0 else {
                for button in [boldButton, italicButton, strikethroughButton, codeButton, linkButton] {
                    button?.tintColor = self.style.normalColor()
                }
                return
            }

            UIView.animate(withDuration: 0.3) {
                for state in states {
                    switch state {
                    case let .bold(value): self.boldButton.tintColor = self.style.color(for: value)
                    case let .italic(value): self.italicButton.tintColor = self.style.color(for: value)
                    case let .strikethrough(value): self.strikethroughButton.tintColor = self.style.color(for: value)
                    case let .keyboard(value): self.codeButton.tintColor = self.style.color(for: value)
                    case let .link(value): self.linkButton.tintColor = self.style.color(for: value)
                    }
                }
            }
        }

        // MARK: Actions
        @objc func processApplyBold() {
            process(.bold(.init()))
        }

        @objc func processApplyItalic() {
            process(.italic(.init()))
        }

        @objc func processApplyStrikethrough() {
            process(.strikethrough(.init()))
        }

        @objc func processApplyCode() {
            process(.keyboard(.init()))
        }

        @objc func processApplyLink() {
            process(.linkView(.init(), { _, _ -> UIView? in nil }))
        }

        @objc func processChangeColor() {
            process(.changeColorView(.init(), nil))
        }

        @objc func processDismissKeyboard() {
            process(.keyboardDismiss)
        }

        func process(_ action: Action) {
            self.model.process(action)
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

        // MARK: Outlets
        var boldButton: UIButton!
        var italicButton: UIButton!
        var strikethroughButton: UIButton!
        var linkButton: UIButton!
        var codeButton: UIButton!

        var changeColorButton: UIButton!
        var dismissKeyboardButton: UIButton!
        
        var toolbarView: CustomTextView.BaseToolbarView!
        var contentView: UIView!

        // MARK: Public API Configurations
        // something that we should put in public api.

        func setupCustomization() {
            self.backgroundColor = self.style.backgroundColor()
            for button in [boldButton, italicButton, strikethroughButton, codeButton, linkButton] {
                button?.tintColor = self.style.normalColor()
            }

            for button in [changeColorButton, dismissKeyboardButton] {
                button?.tintColor = self.style.normalColor()
            }

            self.boldButton.addTarget(self, action: #selector(Self.processApplyBold), for: .touchUpInside)
            self.italicButton.addTarget(self, action: #selector(Self.processApplyItalic), for: .touchUpInside)
            self.strikethroughButton.addTarget(self, action: #selector(Self.processApplyStrikethrough), for: .touchUpInside)
            self.linkButton.addTarget(self, action: #selector(Self.processApplyLink), for: .touchUpInside)
            self.codeButton.addTarget(self, action: #selector(Self.processApplyCode), for: .touchUpInside)

            self.changeColorButton.addTarget(self, action: #selector(Self.processChangeColor), for: .touchUpInside)
            self.dismissKeyboardButton.addTarget(self, action: #selector(Self.processDismissKeyboard), for: .touchUpInside)
        }

        // MARK: Setup
        func setupInteraction() {
            self.userResponse = self.model.$userResponse.dropFirst().sink { [weak self] (pair) in
                let range = pair.range
                let states = pair.states
                self?.update(range: range, states: states)
            }
        }

        func setup() {
            self.setupUIElements()
            self.addLayout()
            self.setupCustomization()
            self.setupInteraction()
        }

        func setupUIElements() {
            self.autoresizingMask = .flexibleHeight
            self.boldButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Marks/Bold"), for: .normal)
                return view
            }()

            self.italicButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Marks/Italic"), for: .normal)
                return view
            }()

            self.strikethroughButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Marks/Strikethrough"), for: .normal)
                return view
            }()

            self.linkButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Marks/Link"), for: .normal)
                return view
            }()

            self.codeButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Marks/Code"), for: .normal)
                return view
            }()

            self.changeColorButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/ChangeColor"), for: .normal)
                return view
            }()

            self.dismissKeyboardButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/General/Keyboard"), for: .normal)
                return view
            }()
            
            self.toolbarView = {
                let view = CustomTextView.BaseToolbarView()
                return view
            }()
            
            for view in [boldButton, italicButton, strikethroughButton, linkButton, codeButton].compactMap({$0}) {
                toolbarView.leftStackView.addArrangedSubview(view)
            }
            
            for view in [changeColorButton, dismissKeyboardButton].compactMap({$0}) {
                toolbarView.rightStackView.addArrangedSubview(view)
            }
                        
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.contentView.addSubview(toolbarView)
            self.addSubview(contentView)
        }

        // MARK: Layout
        func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            
            if let view = self.toolbarView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
        }
        
        // NOTE: To enable auto-layout for input accessory views, you should
        // In parentAccessoryView
        // 1. Set autoresizingMask = .flexibleHeight
        // 2. Set intrinsicContentSize = .zero
        override var intrinsicContentSize: CGSize {
            return .zero
        }
    }
}

extension CustomTextView.HighlightedToolbar {
    // MARK: UserResponse State
    enum State {
        case bold(Bool)
        case italic(Bool)
        case strikethrough(Bool)
        case keyboard(Bool)
        case link(Bool)
    }

    class StatesConvertor {
        static func state(_ style: MarkStyle?) -> State? {
            guard let style = style else { return nil }
            switch style {
            case let .bold(value): return .bold(value)
            case let .italic(value): return .italic(value)
            case let .strikethrough(value): return .strikethrough(value)
            case let .keyboard(value): return .keyboard(value)
            case let .link(value): return .link(!value.isNil)
            default: return nil
            }
        }

        static func states(_ styles: [MarkStyle]) -> [State] {
            styles.compactMap(state)
        }
    }

    // TODO: Switch to (NSRange, [State]) pair instead.
    // We can't just use Pairs in Publishers, HAHAHAHA
    // Shit
    struct UserResponse {
        var range: NSRange = .init()
        var states: [State] = []
        static var zero = Self.init()
        func isZero() -> Bool {
            return self.range == Self.zero.range && self.states.count == Self.zero.states.count
        }
    }

    // MARK: User Action
    enum Action {
        case unknown
        case keyboardDismiss

        // styles
        case bold(NSRange)
        case italic(NSRange)
        case strikethrough(NSRange)
        case keyboard(NSRange)
        case linkView(NSRange, (String, URL?) -> (UIView?))
        case link(NSRange, URL?)
        // link?
        case changeColorView(NSRange, UIView?)
        case changeColor(NSRange, UIColor?, UIColor?)
    }
    
//    struct UserAction {
//        var action: Action = .unknown
//        var view: UIView?
//        static var zero = Self.init()
//    }

    // MARK: ViewModel
    class ViewModel: NSObject, ObservableObject {
        // MARK: Variables
        private var range: NSRange = .init()
        func getRange() -> NSRange {
            return range
        }

        // MARK: Initialization
        override init() {
            self.inputLinkViewModel = .init()
            self.changeColorViewModel = .init()
            
            super.init()
            self.setup()
        }
        
        // MARK: ViewModels
        @ObservedObject var inputLinkViewModel: CustomTextView.HighlightedToolbar.InputLink.ViewModel
        @ObservedObject var changeColorViewModel: CustomTextView.BlockToolbar.ChangeColor.ViewModel

        // MARK: Publishers
        @Published fileprivate var userResponse: UserResponse = .zero
        @Published var userAction: Action = .unknown

        // MARK: Subjects
        var inputLinkViewModelDidChange: AnyCancellable?
        var changeColorViewModelDidChange: AnyCancellable?

        // MARK: Setup
        func setup() {
            let links = self.inputLinkViewModel.$action.map { value -> URL? in
                switch value {
                case .unknown: return nil
                case .decline: return nil
                case let .accept(value): return URL(string: value)
                }
            }
            
            let linksAndRanges = links.map{ [weak self] in (self?.range ?? .init(), $0)}.sink { [weak self] (range, url) in
                self?.userAction = .link(range, url)
            }
            self.inputLinkViewModelDidChange = linksAndRanges
            
            let colorsAndRanges = self.changeColorViewModel.$value.map{ [weak self] in (self?.range ?? .init(), $0.textColor, $0.backgroundColor)}
                .map { pair in Action.changeColor(pair.0, pair.1, pair.2) }.sink { [weak self] action in
                self?.userAction = action
            }
            self.changeColorViewModelDidChange = colorsAndRanges
        }

        //  -> (SelectRange) -> (SelectRange)
        //  -> (ChangeColor) -> (UIColor, UIColor)
        //  -> (SelectRange, (UIColor, UIColor)) -> (...)

        // MARK: Private Setters
        fileprivate func process(_ action: Action) {
            switch action {
            case .unknown: return
            case .keyboardDismiss: self.userAction = .keyboardDismiss
            case .bold: self.userAction = .bold(range)
            case .italic: self.userAction = .italic(range)
            case .strikethrough: self.userAction = .strikethrough(range)
            case .keyboard: self.userAction = .keyboard(range)
            
            // Later we can create view here when we can get current selected text.
            // Whole this setup and cheating with functions will be eliminated when we get underlying model.
            case .linkView: self.userAction = .linkView(range, { (value, url) in
                let viewModel = self.inputLinkViewModel
                viewModel.title = value
                viewModel.link = url?.absoluteString ?? ""
                return CustomTextView.HighlightedToolbar.InputLink.InputViewBuilder.createView(self._inputLinkViewModel)
            })
            case .link(_, _): return
            case let .changeColorView(range, _): self.userAction = .changeColorView(range, CustomTextView.BlockToolbar.ChangeColor.InputViewBuilder.createView(self._changeColorViewModel))
            case .changeColor(_, _, _): return
            }
        }

        // MARK: Public Setters
        func update(range: NSRange, attributedText: NSMutableAttributedString) {
            self.range = range
            // Currently we do not use this entity thats why font is .body
            let modifier = MarkStyleModifier(
                attributedText: attributedText,
                defaultNonCodeFont: .body
            )
            let styles = modifier.getMarkStyles(at: range)
            let states = StatesConvertor.states(styles)
            self.userResponse = .init(range: range, states: states)
        }
    }
}

