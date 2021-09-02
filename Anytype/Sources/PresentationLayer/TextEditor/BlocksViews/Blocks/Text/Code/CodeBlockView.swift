import Combine
import UIKit
import Highlightr
import BlocksModels

final class CodeBlockView: UIView & UIContentView {
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
        addSubview(contentView) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0))
        }
        
        contentView.layoutUsing.stack {
            $0.hStack(
                $0.hGap(fixed: 20),
                $0.vStack(
                    $0.vGap(fixed: 13),
                    $0.hStack(codeSelectButton, $0.hGap()),
                    $0.vGap(fixed: 15),
                    textView,
                    $0.vGap(fixed: 14)
                ),
                $0.hGap(fixed: 20)
            )
        }
    }

    private func applyNewConfiguration() {
        codeSelectButton.setText(currentConfiguration.codeLanguage.rawValue)
        textStorage.language = currentConfiguration.codeLanguage.rawValue
        textStorage.highlightr.highlight(currentConfiguration.content.attrString.string).flatMap {
            textStorage.setAttributedString($0)
        }
        
        let backgroundColor = currentConfiguration.backgroundColor?.color(background: true) ?? UIColor.lightColdGray
        contentView.backgroundColor = backgroundColor
        textView.backgroundColor = backgroundColor
    }
    
    // MARK: - Views
    private let contentView = UIView()
    
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

        return textView
    }()

    private lazy var codeSelectButton: ButtonWithImage = {
        let button = ButtonWithImage()
        button.label.font = .uxBodyRegular
        button.label.textColor = .darkColdGray
        let image = UIImage.codeBlock.arrow
        button.setImage(image)
        
        button.addAction(
            UIAction { [weak self] _ in
                self?.currentConfiguration.showCodeSelection()
            },
            for: .touchUpInside
        )

        return button
    }()
}

extension CodeBlockView: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        currentConfiguration.becomeFirstResponder()
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        currentConfiguration.textDidChange(textView)
    }
}
