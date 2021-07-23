import UIKit

final class URLInputView: UIView {
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.font = .headline
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Paste or type URL".localized,
            attributes: [
                .font: UIFont.headline,
                .foregroundColor: UIColor.grayscale50
            ]
        )
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(
                                    string: "Done".localized,
                                    attributes: [.font: UIFont.headline,
                                                 .foregroundColor: UIColor.pureAmber]),
                                  for: .normal)
        button.setAttributedTitle(NSAttributedString(
                                    string: "Done".localized,
                                    attributes: [.font: UIFont.headline,
                                                 .foregroundColor: UIColor.lightAmber]),
                                  for: .disabled)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.addAction(UIAction(handler: { [weak self]_ in
            guard let self = self,
                  let text = self.textField.text,
                  let url = URL(string: text) else { return }
            self.didCreateURL(url)
        }), for: .touchUpInside)
        button.isEnabled = false
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
            height: Constants.insets.top + (-Constants.insets.bottom) + stackView.intrinsicContentSize.height)
    }
    
    private var notificationToken: NSObjectProtocol?
    private let didCreateURL: (URL) -> Void
    
    init(didCreateURL: @escaping (URL) -> Void) {
        self.didCreateURL = didCreateURL
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .systemBackground
        addTextFieldTextChangeObserver()
        addSubview(stackView)
        stackView.pinAllEdges(to: self, insets: Constants.insets)
        addTopLine()
    }
    
    private func addTextFieldTextChangeObserver() {
        notificationToken = NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: textField,
            queue: .main,
            using: { [weak self] _ in
                guard let self = self else { return }
                self.doneButton.isEnabled = self.textField.text?.isValidURL() ?? false
        })
    }
    
    private func addTopLine() {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .grayscale10
        addSubview(line)
        line.layoutUsing.anchors {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: Constants.lineHeight)
        }
    }
}

extension URLInputView {
    
    private enum Constants {
        static let horizontalElementsSpacing: CGFloat = 10
        static let insets = UIEdgeInsets(top: 12, left: 16, bottom: -12, right: -16)
        static let lineHeight: CGFloat = 1
    }
}
