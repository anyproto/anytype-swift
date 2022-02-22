import Combine
import UIKit
import Highlightr
import BlocksModels

final class CodeBlockView: UIView, BlockContentView {
    private var actionHandler: CodeBlockContentConfiguration.Actions?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func update(with configuration: CodeBlockContentConfiguration) {
        actionHandler = configuration.actions
        applyNewConfiguration(configuration: configuration)
    }

    func update(with state: UICellConfigurationState) {
        textView.isUserInteractionEnabled = state.isEditing
    }

    // MARK: - Setup view

    private func setupViews() {
        addSubview(contentView) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 6, left: 10, bottom: -6, right: -10))
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

    private func applyNewConfiguration(configuration: CodeBlockContentConfiguration) {
        codeSelectButton.setText(configuration.codeLanguage.rawValue)
        textStorage.language = configuration.codeLanguage.rawValue
    
        textStorage.highlightr.highlight(configuration.content.anytypeText.attrString.string).flatMap {
            textStorage.setAttributedString($0)
        }
        
        let backgroundColor = configuration.backgroundColor.map {
            UIColor.Background.uiColor(from: $0)
        } ?? UIColor.Background.grey
        contentView.backgroundColor = backgroundColor
        textView.backgroundColor = backgroundColor
    }
    
    // MARK: - Views
    private let contentView = UIView()
    
    private let textStorage: CodeAttributedString = {
        let textStorage = CodeAttributedString()
        textStorage.highlightr.theme.boldCodeFont = .code
        
        return textStorage
    }()


    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.userInterfaceStyle == .dark {
            textStorage.highlightr.setTheme(to: "gruvbox-dark")
        } else {
            textStorage.highlightr.setTheme(to: "github-gist")
        }
    }

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
        button.label.textColor = .darkGray
        let image = UIImage.codeBlock.arrow
        button.setImage(image)
        
        button.addAction(
            UIAction { [weak self] _ in
                self?.actionHandler?.showCodeSelection()
            },
            for: .touchUpInside
        )

        return button
    }()
}

extension CodeBlockView: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        actionHandler?.becomeFirstResponder()
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        actionHandler?.textDidChange(textView)
    }
}
