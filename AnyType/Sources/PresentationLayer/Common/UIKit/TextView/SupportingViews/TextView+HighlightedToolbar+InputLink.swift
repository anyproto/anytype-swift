import Foundation
import UIKit
import SwiftUI

// MARK: InputLink
extension CustomTextView.HighlightedToolbar {
    enum InputLink {}
}

// MARK: InputLink / Actions
extension CustomTextView.HighlightedToolbar.InputLink {
    enum Action {
        case unknown
        case decline
        case accept(String) // Don't forget to convert to URL.
    }
}

// MARK: InputLink / Style
extension CustomTextView.HighlightedToolbar.InputLink {
    enum Style {
        enum TextField {
            case `default`
            func separatorColor() -> UIColor {
                return .lightGray
            }
        }
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
                case .decline: return .lightGray //self.textColor()
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
extension CustomTextView.HighlightedToolbar.InputLink {
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
//                let view = InputView(title: theViewModel.title, resources: theViewModel.resources, link: theViewModel.link, action: viewModel.projectedValue.action)
//                let controller = UIHostingController(rootView: view)
//                return controller.view
                let view = InputViewAsUIKit().configure(theViewModel.resources).configure(title: theViewModel.title).configure(link: theViewModel.link).configure(action: viewModel.projectedValue.action)
                return view
            }()
            
            view?.backgroundColor = Style.default.backgroundColor()
            // Set flexible width for inputAccessoryView.
            view?.autoresizingMask = .flexibleHeight
            
            let containerView = ContainerView()
            containerView.addView(view)
            containerView.autoresizingMask = .flexibleHeight
            return containerView
        }
    }
    struct InputView: View {
        struct RoundedButtonViewModifier: ViewModifier {
            var style: Style.Button
            func body(content: Content) -> some View {
                content.padding(10)
                    .background(Color(self.style.backgroundColor()))
                    .foregroundColor(Color(self.style.textColor()))
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
                        AnytypeText(self.resources.declineButtonTitle, style: .body)
                    }.modifier(RoundedButtonViewModifier(style: .decline))
                    Spacer().frame(width: 10)
                    Button(action: {
                        self.action = .accept(self.link)
                    }) {
                        AnytypeText(self.resources.acceptButtonTitle, style: .body)
                    }.modifier(RoundedButtonViewModifier(style: .accept))
                    Spacer().frame(width: 10)
                }
            }
        }
    }
}

// MARK: InputLink / ContainerView
extension CustomTextView.HighlightedToolbar.InputLink {
    class ContainerView: UIInputView {
        override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
            super.init(frame: frame, inputViewStyle: inputViewStyle)
            self.allowsSelfSizing = true
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
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
    }
}

// MARK: InputLink / InputView as UIKit
extension CustomTextView.HighlightedToolbar.InputLink {
    class InputViewAsUIKit: UIView {
        // MARK: Outlets
        private var contentView: UIView!
        private var textViewsStackView: UIStackView!
        private var buttonsStackView: UIStackView!
        
        private var titleTextField: TextField!
        private var linkTextField: TextField!
        private var declineButton: Button!
        private var acceptButton: Button!
        
        // MARK: Actions
        @Binding var action: Action
        
        // MARK: Actions / UIKit
        @objc func processDeclineButton() {
            self.action = .decline
        }
        
        @objc func processAcceptButton() {
            self.action = .accept(self.linkTextField.text)
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
            _ = self.titleTextField.configure(title)
            return self
        }
        
        func configure(link: String?) -> Self {
            self.link = link
            _ = self.linkTextField.configure(link)
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
                view.spacing = CustomTextView.Layout.StackViewSpacing.default.size()
                return view
            }()
            
            self.buttonsStackView = {
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .horizontal
                view.distribution = .fillEqually
                view.spacing = CustomTextView.Layout.StackViewSpacing.default.size()
                return view
            }()
            
            self.titleTextField = {
                let view = TextField()
                    .configure(TextField.Resources.init(title: self.title, placeholder: self.resources.titlePlaceholder, separatorBackgroundColor: Style.TextField.default.separatorColor()))
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.linkTextField = {
                let view = TextField()
                    .configure(TextField.Resources.init(title: self.title, placeholder: self.resources.linkPlaceholder, separatorBackgroundColor: Style.TextField.default.separatorColor()))
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.declineButton = {
                let style = Style.Button.decline
                let title = self.resources.declineButtonTitle
                
                let view: Button = Button.init(frame: .zero)
                .configure(Button.Resources.init(textColor: style.textColor(), backgroundColor: style.backgroundColor(), borderColor: style.borderColor()))
                .configure(title)
                .configure { [weak self] in
                    self?.processDeclineButton()
                }
                
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.acceptButton = {
                let style = Style.Button.accept
                let title = self.resources.acceptButtonTitle
                
                let view: Button = Button.init(frame: .zero)
                .configure(Button.Resources.init(textColor: style.textColor(), backgroundColor: style.backgroundColor(), borderColor: style.borderColor()))
                .configure(title)
                .configure { [weak self] in
                    self?.processAcceptButton()
                }
                
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
                                                
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
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: CustomTextView.Layout.default.leadingOffset()).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: CustomTextView.Layout.default.trailingOffset()).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: CustomTextView.Layout.default.topOffset()).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: CustomTextView.Layout.default.bottomOffset()).isActive = true
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

// MARK: InputLink / InputView as UIKit / Components / TextField
extension CustomTextView.HighlightedToolbar.InputLink.InputViewAsUIKit {
    class TextField: UIView {
        class SeparatorView: UIView {
            // TODO: Move this constant to style someday.
            var intristicHeight: CGFloat = 1.0
            func configure(_ height: CGFloat) -> Self {
                self.intristicHeight = height
                return self
            }
            override var intrinsicContentSize: CGSize {
                var size = super.intrinsicContentSize
                size.height = self.intristicHeight
                return size
            }
        }
        struct Resources {
            var title: String?
            var placeholder: String?
            var separatorBackgroundColor: UIColor?
        }
        
        // MARK: Outlets
        private var contentView: UIView!
        private var stackView: UIStackView!
        private var textField: UITextField!
        private var separatorView: SeparatorView!
                
        // MARK: Resources
        // public accessor for text
        var text: String { self.title ?? "" }
        private var title: String? {
            get {
                self.textField.text
            }
            set {
                self.textField.text = newValue
            }
        }
        
        private var resources: Resources = .init()
        
        // MARK: Configuration
        func configure(_ title: String?) -> Self {
            self.title = title
            return self
        }
        
        func configure(_ resources: Resources) -> Self {
            self.resources = resources
            self.title = resources.title
            self.textField.placeholder = resources.placeholder
            self.separatorView.backgroundColor = resources.separatorBackgroundColor
            return self
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
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        // MARK: UI Elements
        private func setupUIElements() {
            self.autoresizingMask = .flexibleHeight
            
            self.textField = {
                let view = UITextField()
                view.autocorrectionType = .no
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.separatorView = {
                let view = SeparatorView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            _ = self.configure(nil).configure(.init())
            
            self.stackView = {
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .vertical
                view.distribution = .fillProportionally
                return view
            }()
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            for view in [textField, separatorView].compactMap({$0}) {
                self.stackView.addArrangedSubview(view)
            }
            
            self.contentView.addSubview(self.stackView)
            self.addSubview(self.contentView)
        }
        
        // MARK: Layout
        private func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: CustomTextView.Layout.default.leadingOffset()).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: CustomTextView.Layout.default.trailingOffset()).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            
            if let view = self.stackView, let superview = view.superview {
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

// MARK: InputLink / InputView as UIKit / Components / Button
extension CustomTextView.HighlightedToolbar.InputLink.InputViewAsUIKit {
    class Button: UIView {
        struct Resources {
            var textColor: UIColor?
            var backgroundColor: UIColor?
            var borderColor: UIColor?
        }
        
        // MARK: Outlets
        private var contentView: UIView!
        private var button: UIButton!
        
        // MARK: Action
        var buttonPressed: () -> () = {}
        
        // MARK: Actions / UIKit
        @objc func processButtonPressed() {
            self.buttonPressed()
        }
        
        // MARK: Resources
        private var title: String? = ""
        private var resources: Resources = .init()
        
        // MARK: Configuration
        func configure(_ title: String?) -> Self {
            self.title = title
            self.button.setTitle(title, for: .normal)
            return self
        }
        
        func configure(_ resources: Resources) -> Self {
            self.resources = resources
            self.button.setTitleColor(resources.textColor, for: .normal)
            self.button.backgroundColor = resources.backgroundColor
            self.button.layer.borderWidth = 1.0
            self.button.layer.borderColor = resources.borderColor?.cgColor
            return self
        }
        
        func configure(_ buttonPressed: @escaping () -> ()) -> Self {
            self.buttonPressed = buttonPressed
            return self
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
        private func setup() {
            self.setupUIElements()
            self.addLayout()
        }
        
        // MARK: UI Elements
        private func setupUIElements() {
            self.autoresizingMask = .flexibleHeight
                
            self.button = {
                let view = UIButton(type: .system)
                view.addTarget(self, action: #selector(processButtonPressed), for: .touchUpInside)
                view.layer.cornerRadius = 8
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
                                                            
            self.button.setTitle(self.title, for: .normal)
            
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.contentView.addSubview(self.button)
            self.addSubview(self.contentView)
        }
        
        // MARK: Layout
        private func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: CustomTextView.Layout.default.leadingOffset()).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: CustomTextView.Layout.default.trailingOffset()).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            
            if let view = self.button, let superview = view.superview {
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
