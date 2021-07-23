import Combine
import UIKit
import Highlightr
import BlocksModels

final class CodeBlockContentView: UIView & UIContentView {
    private var currentConfiguration: CodeBlockContentConfiguration
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let configuration = newValue as? CodeBlockContentConfiguration else { return }
            guard currentConfiguration != configuration else { return }
            currentConfiguration = configuration
            
            applyNewConfiguration()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(configuration: CodeBlockContentConfiguration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        
        setupViews()
        applyNewConfiguration()
    }

    // MARK: - Setup view

    private func setupViews() {
        addSubview(textView)
        addSubview(codeSelectButton)

        textView.edgesToSuperview(insets: UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0))

        NSLayoutConstraint.activate([
            codeSelectButton.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            codeSelectButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])

        codeSelectButton.addAction(UIAction { [weak self] _ in
            self?.currentConfiguration.showCodeSelection()
        }, for: .touchUpInside)
    }

    private func applyNewConfiguration() {
        codeSelectButton.setText(currentConfiguration.codeLanguage.rawValue)
        textStorage.language = currentConfiguration.codeLanguage.rawValue
        textStorage.highlightr.highlight(currentConfiguration.content.attributedText.string).flatMap {
            textStorage.setAttributedString($0)
        }
        
        textView.backgroundColor = currentConfiguration.backgroundColor?.color(background: true) ?? UIColor.lightColdGray
    }
    
    // MARK: - Views
    
    private let textStorage: CodeAttributedString = {
        let textStorage = CodeAttributedString()
        textStorage.highlightr.setTheme(to: "github-gist")
        textStorage.highlightr.theme.boldCodeFont = .code
        
        return textStorage
    }()

    private lazy var textView: UITextView = {
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)

        let textView = UITextView(frame: .zero, textContainer: textContainer)
        textView.isScrollEnabled = false
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.delegate = self
        
        textView.textContainerInset = UIEdgeInsets(top: 50, left: 20, bottom: 24, right: 20)

        return textView
    }()

    private let codeSelectButton: ButtonWithImage = {
        let button = ButtonWithImage()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.label.font = UIFont.body
        button.label.textColor = MiddlewareColor.grey.color(background: false)
        let image = UIImage(named: "TextEditor/Toolbar/turn_into_arrow")
        button.setImage(image)

        return button
    }()
}

extension CodeBlockContentView: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        currentConfiguration.becomeFirstResponder()
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        currentConfiguration.textDidChange(textView)
    }
}
