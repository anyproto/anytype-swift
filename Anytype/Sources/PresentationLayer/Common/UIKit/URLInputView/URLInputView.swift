import UIKit
import AnytypeCore

final class URLInputView: UIView {
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.font = .uxBodyRegular
        textField.clearButtonMode = .always
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.attributedPlaceholder = NSAttributedString(
            string: Loc.pasteOrTypeURL,
            attributes: [
                .font: UIFont.uxBodyRegular,
                .foregroundColor: UIColor.Text.secondary
            ]
        )
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(
                                    string: Loc.done,
                                    attributes: [.font: UIFont.uxBodyRegular,
                                                 .foregroundColor: UIColor.System.amber100]),
                                  for: .normal)
        button.setAttributedTitle(NSAttributedString(
                                    string: Loc.done,
                                    attributes: [.font: UIFont.uxBodyRegular,
                                                 .foregroundColor: UIColor.VeryLight.orange]),
                                  for: .disabled)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.didTapDoneButton()
        }), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, doneButton])
        stackView.axis = .horizontal
        stackView.spacing = Constants.horizontalElementsSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width,
            height: Constants.insets.top + Constants.insets.bottom + stackView.intrinsicContentSize.height)
    }
    
    private var notificationToken: (any NSObjectProtocol)?
    private let didSetURL: (AnytypeURL?) -> Void
    
    init(
        url: AnytypeURL? = nil,
        didSetURL: @escaping (AnytypeURL?) -> Void
    ) {
        self.didSetURL = didSetURL
        super.init(frame: .zero)
        setup()
        textField.text = url?.absoluteString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .systemBackground
        addTextFieldTextChangeObserver()
        
        addSubview(stackView)
        addSubview(stackView) {
            if UIDevice.isPad {
                $0.pin(to: readableContentGuide, excluding: [.top, .bottom])
                $0.top.equal(to: topAnchor, constant: Constants.insets.top)
                $0.bottom.equal(to: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.insets.bottom)
            } else {
                $0.pinToSuperview(excluding: [.bottom], insets: Constants.insets)
                $0.bottom.equal(to: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.insets.bottom)
            }
        }
        
        addTopLine()
        updateDoneButton()
    }
    
    private func addTextFieldTextChangeObserver() {
        notificationToken = NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: textField,
            queue: .main,
            using: { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.updateDoneButton()
                }
            })
    }
    
    private func addTopLine() {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .Shape.tertiary
        addSubview(line)
        line.layoutUsing.anchors {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: Constants.lineHeight)
        }
    }
    
    private func didTapDoneButton() {
        if textField.text?.isEmpty ?? true {
            didSetURL(nil)
            return
        }
        if let text = textField.text, let url = AnytypeURL(string: text) {
            didSetURL(url)
        }
    }
    
    private func updateDoneButton() {
        let isValidURL = textField.text?.isValidURL() ?? false
        let isEmptyURL = textField.text?.isEmpty ?? true
        doneButton.isEnabled = isValidURL || isEmptyURL
    }
}

extension URLInputView {
    
    private enum Constants {
        static let horizontalElementsSpacing: CGFloat = 10
        static let insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        static let lineHeight: CGFloat = 1
    }
}
