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
extension TextView {
    class HighlightedAccessoryView: UIView {
        typealias Style = TextView.Style
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
                    case let .code(value): self.codeButton.tintColor = self.style.color(for: value)
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
            process(.code(.init()))
        }

        @objc func processApplyLink() {
            //            process(.bold(range))
        }

        @objc func processChangeColor() {
            process(.changeColor(.init(), nil))
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
        
        var toolbarView: BaseToolbarView!
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
            self.userResponse = self.model.$userResponse.dropFirst().sink { (pair) in
                print("Value! \(pair)")
                let range = pair.range
                let states = pair.states
                self.update(range: range, states: states)
            }
        }

        func setup() {
            self.setupUIElements()
            self.addLayout()
            self.setupCustomization()
            self.setupInteraction()
        }

        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false

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
                let view = BaseToolbarView()
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
                
        override var intrinsicContentSize: CGSize {
            return self.toolbarView.intrinsicContentSize
        }
    }
}

// MARK: KeyboardHandler, move to services.
// We could, for example, subscribe on event?
// But actually, we don't want to store this object.
extension TextView {
    class KeyboardHandler {
        static var shared: KeyboardHandler = .init()
        func dismiss() {
            DispatchQueue.main.async {
                UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

extension TextView.HighlightedAccessoryView {
    // MARK: UserResponse State
    enum State {
        case bold(Bool)
        case italic(Bool)
        case strikethrough(Bool)
        case code(Bool)
        case link(Bool)
    }

    class StatesConvertor {
        static func state(_ style: TextView.MarkStyle?) -> State? {
            guard let style = style else { return nil }
            switch style {
            case let .bold(value): return .bold(value)
            case let .italic(value): return .italic(value)
            case let .strikethrough(value): return .strikethrough(value)
            case let .keyboard(value): return .code(value)
            default: return nil
            }
        }

        static func states(_ styles: [TextView.MarkStyle]) -> [State] {
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
        case code(NSRange)
        // link?
        case changeColor(NSRange, UIView?)
    }

    // MARK: ViewModel
    class ViewModel: NSObject, ObservableObject {
        // MARK: Variables
        private var range: NSRange = .init()
        func getRange() -> NSRange {
            return range
        }
        @ObservedObject var changeColorViewModel: TextView.BlockToolbar.ChangeColor.ViewModel

        // MARK: Initialization
        override init() {
            self.changeColorViewModel = .init()
            super.init()
            self.setup()
        }

        // MARK: Publishers
        @Published fileprivate var userResponse: UserResponse = .zero
        @Published var userAction: Action = .unknown

        // MARK: Subjects
        var changeColorViewModelDidChange: AnyCancellable?
        var changeColorSubject: PassthroughSubject<(NSRange, UIColor?, UIColor?), Never> = .init()

        // MARK: Setup
        func setup() {
            let colors = self.changeColorViewModel.$value.map{($0.textColor, $0.backgroundColor)}
            let just = Just(self.range).scan(self.range) { _,_ -> NSRange in
                
//                print("range: \(self.range)")
                return self.range
            }.filter { (range) -> Bool in
                range.length == 0
            }.last()
            
            let dirty = colors.map{[weak self] in (self?.range ?? .init(), $0.0, $0.1)}.subscribe(self.changeColorSubject)
            _ = Publishers.CombineLatest(just, colors).map{($0.0, $0.1.0, $0.1.1)}.subscribe(self.changeColorSubject)
            self.changeColorViewModelDidChange = dirty
        }

        //  -> (SelectRange) -> (SelectRange)
        //  -> (ChangeColor) -> (UIColor, UIColor)
        //  -> (SelectRange, (UIColor, UIColor)) -> (...)

        // MARK: Private Setters
        fileprivate func process(_ action: Action) {
            switch action {
            case .unknown: return
            case .keyboardDismiss: TextView.KeyboardHandler.shared.dismiss()
            case .bold: self.userAction = .bold(range)
            case .italic: self.userAction = .italic(range)
            case .strikethrough: self.userAction = .strikethrough(range)
            case .code: self.userAction = .code(range)
                // TODO: Show input link.
            //            case .link: return //self.userAction = .link(range)
            case let .changeColor(range, _): self.userAction = .changeColor(range, TextView.BlockToolbar.ChangeColor.InputViewBuilder.createView(self._changeColorViewModel))
            }
        }

        // MARK: Public Setters
        func update(range: NSRange, attributedText: NSMutableAttributedString) {
            self.range = range
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText)
            let styles = modifier.getMarkStyles(at: .range(range))
            let states = StatesConvertor.states(styles)
            self.userResponse = .init(range: range, states: states)
        }
    }
}

