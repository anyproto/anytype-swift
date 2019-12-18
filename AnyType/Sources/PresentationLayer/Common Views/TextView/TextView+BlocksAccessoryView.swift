//
//  TextView+BlocksAccessoryView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 10.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// We have several views here.
extension TextView {
    enum BlockToolbar {}
}

// MARK: BlockToolbar
extension TextView.BlockToolbar {
    class AccessoryView: UIView {
        typealias Style = TextView.Style
        // MARK: Variables
        var style: Style = .default
        var model: ViewModel = .init()
        var userResponse: AnyCancellable?

        // MARK: Updates
        func update(state: State) {
            func button(for state: State) -> UIButton? {
                switch state {
                case .unknown: return nil
                case .addBlock: return self.addBlockButton
                case .turnIntoBlock: return self.turnIntoBlockButton
                case .changeColor: return self.changeColorButton
                case .editBlock: return self.editActionsButton
                }
            }

            let selectedButton = button(for: state)
            let otherButtons = [addBlockButton, turnIntoBlockButton, changeColorButton, editActionsButton].filter { $0 != selectedButton }

            UIView.animate(withDuration: 0.3) {
                for button in otherButtons {
                    button?.backgroundColor = self.style.normalColor()
                }
                selectedButton?.backgroundColor = self.style.highlightedColor()
            }
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

        // MARK: Actions
        @objc func processAddBlock() {
            process(.addBlock)
        }

        @objc func processTurnIntoBlock() {
            process(.turnIntoBlock)
        }

        @objc func processChangeColor() {
            process(.changeColor)
        }

        @objc func processEditActions() {
            process(.editBlock)
        }
        
        @objc func processDismissKeyboard() {
            process(.keyboardDismiss)
        }

        func process(_ action: Action) {
            self.model.process(action)
        }

        // MARK: Public API Configurations
        // something that we should put in public api.

        func setupCustomization() {
            self.backgroundColor = self.style.backgroundColor()
            for button in [addBlockButton, turnIntoBlockButton, changeColorButton, editActionsButton, dismissKeyboardButton] {
                button?.tintColor = self.style.normalColor()
            }

            self.addBlockButton.addTarget(self, action: #selector(Self.processAddBlock), for: .touchUpInside)
            self.turnIntoBlockButton.addTarget(self, action: #selector(Self.processTurnIntoBlock), for: .touchUpInside)
            self.changeColorButton.addTarget(self, action: #selector(Self.processChangeColor), for: .touchUpInside)
            self.editActionsButton.addTarget(self, action: #selector(Self.processEditActions), for: .touchUpInside)
            self.dismissKeyboardButton.addTarget(self, action: #selector(Self.processDismissKeyboard), for: .touchUpInside)
        }

        func setupInteraction() {
            self.userResponse = self.model.$userResponse.dropFirst().sink { (state) in
                print("Value! \(state)")
                self.update(state: state)
            }
        }

        // MARK: Customization
        var insets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)

        // MARK: Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
            self.setupCustomization()
            self.setupInteraction()
        }

        // MARK: UI Elements
        var addBlockButton: UIButton!
        var turnIntoBlockButton: UIButton!
        var leftStackView: UIStackView!

        var changeColorButton: UIButton!
        var editActionsButton: UIButton!
        var dismissKeyboardButton: UIButton!
        var rightStackView: UIStackView!

        var contentView: UIView!

        // MARK: Setup UI Elements
        func setupUIElements() {

            // UIView

            self.translatesAutoresizingMaskIntoConstraints = false

            self.addBlockButton = { () -> UIButton in
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/AddBlock"), for: .normal)
                return view
            }()

            self.turnIntoBlockButton = { () -> UIButton in
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/TurnIntoBlock"), for: .normal)
                return view
            }()

            self.leftStackView = { () -> UIStackView in
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .horizontal
                view.distribution = .fillEqually
                return view
            }()
            
            self.changeColorButton = { () -> UIButton in
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/ChangeColor"), for: .normal)
                return view
            }()

            self.editActionsButton = { () -> UIButton in
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/EditActions"), for: .normal)
                return view
            }()
            
            self.dismissKeyboardButton = { () -> UIButton in
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/General/Keyboard"), for: .normal)
                return view
            }()
            
            self.rightStackView = {  () -> UIStackView in
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .horizontal
                view.distribution = .fillEqually
                return view
            }()

            self.leftStackView.addArrangedSubview(self.addBlockButton)
            self.leftStackView.addArrangedSubview(self.turnIntoBlockButton)
            
            self.rightStackView.addArrangedSubview(self.changeColorButton)
            self.rightStackView.addArrangedSubview(self.editActionsButton)
            self.rightStackView.addArrangedSubview(self.dismissKeyboardButton)

            self.contentView = { () -> UIView in
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.contentView.addSubview(self.leftStackView)
            self.contentView.addSubview(self.rightStackView)
            self.addSubview(contentView)
        }

        // MARK: Layout
        func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                view.leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
                view.rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            if let view = self.leftStackView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16.0).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
//                view.rightAnchor.constraint(greaterThanOrEqualTo: rightView.leftAnchor, constant: -10.0).isActive = true
                view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.20, constant: 0.0).isActive = true
            }
            if let view = self.rightStackView, let superview = view.superview {
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -16.0).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
                view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.30, constant: 0.0).isActive = true
            }
        }

        override var intrinsicContentSize: CGSize {
            var size = self.addBlockButton.intrinsicContentSize
            size.width += self.insets.left + self.insets.right
//            size.height += self.insets.top + self.insets.bottom
            size.height = 48
            return size
        }
    }
}

// MARK: ViewModel
extension TextView.BlockToolbar {
    // MARK: Action
    enum Action {
        case unknown
        case addBlock
        case turnIntoBlock
        case changeColor
        case editBlock
        case keyboardDismiss
    }
    // MARK: State
    enum State {
        case unknown
        case addBlock
        case turnIntoBlock
        case changeColor
        case editBlock
    }
    struct UserAction {
        var action: Action = .unknown
        var view: UIView?
        static var zero = Self.init()
    }
    
    // MARK: ViewModel
    class ViewModel: NSObject, ObservableObject {
        // MARK: Initialization
        override init() {
            self.turnIntoBlockViewModel = .init()
            self.addBlockViewModel = .init()
            self.changeColorViewModel = .init()
            self.editActionsViewModel = .init()
            super.init()
            self.setup()
        }

        // MARK: Setup
        func setup() {
            // WARN: Don't call this function outside of `.init()`
            // NOTE: We should drop first notification in case of setup() function in `.init()`
            self.addBlockViewModelDidChanged = (self.addBlockViewModel.value).dropFirst().sink { (value) in
                print("AddBlock Model!: \(String(describing: value.0)) \(String(describing: value.1)) \(value.2.types)")
            }
            self.changeColorViewModelDidChangeColor = (self.changeColorViewModel.$value).dropFirst().sink { (value) in
                let textColor = value.textColor
                let backgroundColor = value.backgroundColor
                print("TextColor! \(String(describing: textColor)) \n BackgroundColor! \(String(describing: backgroundColor))")
            }
        }

        // MARK: Publishers
        @Published fileprivate var userResponse: State = .unknown
        @Published var userAction: UserAction = .zero

        // MARK: Streams
        var changeColorViewModelDidChangeColor: AnyCancellable?
        var addBlockViewModelDidChanged: AnyCancellable?

        // MARK: ViewModels
        @ObservedObject var turnIntoBlockViewModel: TurnIntoBlock.ViewModel
        @ObservedObject var addBlockViewModel: AddBlock.ViewModel
        @ObservedObject var changeColorViewModel: ChangeColor.ViewModel
        @ObservedObject var editActionsViewModel: EditActions.ViewModel

        // MARK: Private Setters
        fileprivate func process(_ action: Action) {
            switch action {
            case .unknown: return
            case .addBlock: self.userAction = .init(action: action, view: AddBlock.InputViewBuilder.createView(self._addBlockViewModel))
            case .turnIntoBlock: self.userAction = .init(action: action, view: TurnIntoBlock.InputViewBuilder.createView(self._turnIntoBlockViewModel))
            case .changeColor: self.userAction = .init(action: action, view: ChangeColor.InputViewBuilder.createView(self._changeColorViewModel))
            case .editBlock: self.userAction = .init(action: action, view: EditActions.InputViewBuilder.createView(self._editActionsViewModel))
            case .keyboardDismiss: TextView.KeyboardHandler.shared.dismiss()
            }
        }
    }
}
