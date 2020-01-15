//
//  TextView+HighlightedToolbar.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.01.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension TextView {
    enum HighlightedToolbar {}
}

// MARK: InputLink
extension TextView.HighlightedToolbar {
    enum InputLink {}
}

// MARK: InputLink / Actions
extension TextView.HighlightedToolbar.InputLink {
    enum Action {
        case unknown
        case decline
        case accept(String) // Don't forget to convert to URL.
    }
}

// MARK: InputLink / Style
extension TextView.HighlightedToolbar.InputLink {
    enum Style {
        enum Button {
            case decline, accept
            func backgroundColor() -> UIColor {
                switch self {
                case .decline: return Style.presentation.backgroundColor()
                case .accept: return .orange
                }
            }
            func textColor() -> UIColor {
                switch self {
                case .decline: return .darkGray
                case .accept: return .white
                }
            }
            func borderColor() -> UIColor {
                switch self {
                case .decline: return .lightGray//self.textColor()
                case .accept: return self.backgroundColor()
                }
            }
        }
        static let `default`: Self = .presentation
        case presentation
        func backgroundColor() -> UIColor {
            switch self {
            case .presentation: return .init(red: 0.953, green: 0.949, blue: 0.925, alpha: 1) // #F3F2EC
            }
        }
    }
}


// MARK: InputLink / View / SwiftUI
extension TextView.HighlightedToolbar.InputLink {
    struct Resources {
        var titlePlaceholder = "Type link text"
        var linkPlaceholder = "Paste or type a URL"
        var declineButtonTitle = "Unlink"
        var acceptButtonTitle = "Link"
    }
    class ViewModel: NSObject, ObservableObject {
        var title = ""
        var link = ""
        var resources = Resources()
        @Published var action: Action = .unknown
    }
    class InputViewBuilder {
        class func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
            let view: UIView? = {
                let theViewModel = viewModel.wrappedValue
                let view = InputView(title: theViewModel.title, resources: theViewModel.resources, link: theViewModel.link, action: viewModel.projectedValue.action)
                let controller = UIHostingController(rootView: view)
                return controller.view
//                let view = CustomInputView().configure(theViewModel.resources).configure(title: theViewModel.title).configure(link: theViewModel.link).configure(action: viewModel.projectedValue.action)
//                return view
            }()
            
            view?.backgroundColor = Style.default.backgroundColor()
            // Set flexible width for inputAccessoryView.
            view?.autoresizingMask = .flexibleHeight
            
            let containerView = CustomContainerView()
            containerView.addView(view)
            containerView.autoresizingMask = .flexibleHeight
            return containerView
        }
        class func createViewController(_ viewModel: ObservedObject<ViewModel>) -> UIInputViewController? {
            let view = self.createView(viewModel)
            let controller = CustomInputViewController()
            controller.addView(view)
            return controller
        }
    }
    struct InputView: View {
        struct RoundedButtonViewModifier: ViewModifier {
            var style: Style.Button
            func body(content: Content) -> some View {                content.padding(10).background(Color(self.style.backgroundColor())).foregroundColor(Color(self.style.textColor()))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(Color(self.style.borderColor()), lineWidth: 1)
                )
            }
        }
        struct FlexibleWidthViewModifier: ViewModifier {
            func body(content: Content) -> some View {
                content.frame(minWidth: 10, idealWidth: 10, maxWidth: nil, alignment: .center)
            }
        }

        @State var title = ""
        var resources = Resources()
        @State var link = ""
        @Binding var action: Action
        var body: some View {
            VStack {
//                Rectangle().accentColor(.gray)
//                Spacer(minLength: 10).frame(width: 1.0, height: 10, alignment: .center)
                
                TextField(self.resources.titlePlaceholder, text: self.$title).disableAutocorrection(true)
                TextField(self.resources.linkPlaceholder, text: self.$link).disableAutocorrection(true)
                HStack {
                    Spacer().frame(width: 10)
                    Button(action: {
                        self.action = .decline
                    }) {
                        Text(self.resources.declineButtonTitle)
                    }.modifier(RoundedButtonViewModifier(style: .decline))
                    Spacer().frame(width: 10)
                    Button(action: {
                        self.action = .accept(self.link)
                    }) {
                        Text(self.resources.acceptButtonTitle)
                    }.modifier(RoundedButtonViewModifier(style: .accept))
                    Spacer().frame(width: 10)
                }
            }
        }
    }
}

// MARK: InputLink / View / UIKit
extension TextView.HighlightedToolbar.InputLink {
    class CustomInputViewController: UIInputViewController {
        override var canBecomeFirstResponder: Bool { true }
        func addView(_ view: UIView?) {
            if let view = view {
                self.view.addSubview(view)
                self.addViewLayout(view)
            }
        }
        private func addViewLayout(_ view: UIView?) {
            if let view = view, let superview = view.superview {
                let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ]
                NSLayoutConstraint.activate(constraints)
            }
        }
    }
}
extension TextView.HighlightedToolbar.InputLink {
    class CustomContainerView: UIView {
        func addView(_ view: UIView?) {
            view?.translatesAutoresizingMaskIntoConstraints = false
            if let view = view {
                self.addSubview(view)
                self.addLayout(view)
            }
        }
        private func addLayout(_ view: UIView?) {
            if let view = view, let superview = view.superview {
                let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ]
                NSLayoutConstraint.activate(constraints)
            }
        }
        override var canBecomeFirstResponder: Bool {
            return true
        }
        override var intrinsicContentSize: CGSize {
            if let view = self.subviews.first {
                return view.intrinsicContentSize
            }
            return super.intrinsicContentSize
        }
    }
    
    class CustomInputView: UIView {
        // MARK: Views
        class TextField: UITextField {
            var theNextResponder: UIResponder? = nil
            override var next: UIResponder? { theNextResponder ?? super.next }
            override var canBecomeFirstResponder: Bool { true }
            override var canResignFirstResponder: Bool { false }
        }
        // MARK: Outlets
        private var contentView: UIView!
        private var textViewsStackView: UIStackView!
        private var buttonsStackView: UIStackView!
        
        private var titleTextField: TextField!
        private var linkTextField: TextField!
        private var declineButton: UIButton!
        private var acceptButton: UIButton!
        
        // MARK: Actions
        @Binding var action: Action
        
        // MARK: Actions / UIKit
        @objc func processDeclineButton() {
            self.action = .decline
        }
        
        @objc func processAcceptButton() {
            self.action = .accept(self.linkTextField.text ?? "")
        }
        
        // MARK: Resources
        private var title: String? = ""
        private var link: String? = ""
        private var resources = Resources()
        
        // MARK: Configuration
        func configure(_ resources: Resources) -> Self {
            self.resources = resources
            return self
        }
        
        func configure(title: String?) -> Self {
            self.title = title
            self.titleTextField.text = self.title
            return self
        }
        
        func configure(link: String?) -> Self {
            self.link = link
            self.linkTextField.text = self.link
            return self
        }
        
        func configure(action: Binding<Action>) -> Self {
            self._action = action
            return self
        }
        
        // MARK: Initialization
        override init(frame: CGRect) {
            _action = Binding(get: {
                return Action.unknown
            }, set: { (value) in
            })
            super.init(frame: frame)
            self.setup()
        }

        required init?(coder: NSCoder) {
            _action = Binding(get: {
                return Action.unknown
            }, set: { (value) in
            })
            super.init(coder: coder)
            self.setup()
        }
        
        // MARK: Setup
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        // MARK: UI Elements
        private func setupUIElements() {
            self.autoresizingMask = .flexibleHeight
            
            self.textViewsStackView = {
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .vertical
                view.distribution = .fillEqually
                return view
            }()
            
            self.buttonsStackView = {
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .horizontal
                view.distribution = .fillEqually
                return view
            }()
            
            self.titleTextField = {
                let view = TextField()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.linkTextField = {
                let view = TextField()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.declineButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.acceptButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.titleTextField.placeholder = self.resources.titlePlaceholder
            self.titleTextField.text = "Title"//self.title
            self.linkTextField.placeholder = self.resources.linkPlaceholder
            self.linkTextField.text = "Link"//self.link
            
            for textField in [titleTextField, linkTextField].compactMap({$0}) {
                textField.autocorrectionType = .no
//                textField.theNextResponder = self
            }
            
            self.declineButton.setTitle(self.resources.declineButtonTitle, for: .normal)
            self.acceptButton.setTitle(self.resources.acceptButtonTitle, for: .normal)
            
            self.declineButton.addTarget(self, action: #selector(processDeclineButton), for: .touchUpInside)
            self.acceptButton.addTarget(self, action: #selector(processAcceptButton), for: .touchUpInside)
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            for view in [declineButton, acceptButton].compactMap({$0}) {
                self.buttonsStackView.addArrangedSubview(view)
            }
            
            for view in [titleTextField, linkTextField, buttonsStackView].compactMap({$0}) {
                self.textViewsStackView.addArrangedSubview(view)
            }
            
            self.contentView.addSubview(self.textViewsStackView)
            self.addSubview(self.contentView)
        }
        
        // MARK: Layout
        private func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: TextView.Layout.default.leadingOffset()).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: TextView.Layout.default.trailingOffset()).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            
            if let view = self.textViewsStackView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
        }
        
        override var intrinsicContentSize: CGSize {
            return .zero
        }
    }
}
