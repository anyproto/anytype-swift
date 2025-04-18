import Combine
import UIKit
@preconcurrency import Highlightr
import Services

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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            textStorage.highlightr.setTheme(to: traitCollection.userInterfaceStyle.themeName)
        }
    }

    func update(with configuration: CodeBlockContentConfiguration) {
        actionHandler = configuration.actions
        applyNewConfiguration(configuration: configuration)
    }

    func update(with state: UICellConfigurationState) {
        textView.isOpenedForPreview = state.isLocked
        codeSelectButton.isUserInteractionEnabled = !state.isLocked
        textView.isUserInteractionEnabled = state.isEditing
    }

    // MARK: - Setup view

    private func setupViews() {
        addSubview(contentView) {
            $0.pinToSuperview()
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
        codeSelectButton.setText(configuration.codeLanguage.title)
        textStorage.language = configuration.codeLanguage.higlighterCode
        textStorage.highlightr.setTheme(to: traitCollection.userInterfaceStyle.themeName)
    
        textStorage.highlightr.highlight(configuration.anytypeText.attrString.string, as: configuration.codeLanguage.higlighterCode).flatMap {
            textStorage.setAttributedString($0)
        }
        
        let backgroundColor = configuration.backgroundColor.map {
            UIColor.VeryLight.uiColor(from: $0)
        } ?? UIColor.VeryLight.grey
        contentView.backgroundColor = backgroundColor
        textView.backgroundColor = backgroundColor
    }
    
    // MARK: - Views
    private let contentView = UIView()
    
    private let textStorage: CodeAttributedString = {
        let textStorage = CodeAttributedString(highlightr: Highlightr.shared) // use shared Highlightr for perfomance
        textStorage.highlightr.theme.boldCodeFont = .code
        
        return textStorage
    }()

    private lazy var textView: LockableTextView = {
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)

        let textView = LockableTextView(frame: .zero, textContainer: textContainer)
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
        let image = UIImage(asset: .TextEditor.turnIntoArrow)
        button.setImage(image)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        
        button.addAction(
            UIAction { [weak self] _ in
                self?.actionHandler?.showCodeSelection()
            },
            for: .touchUpInside
        )

        return button
    }()
}

private class LockableTextView: UITextView {
    var isOpenedForPreview = false

    override var canBecomeFirstResponder: Bool {
        isOpenedForPreview
            ? false
            : super.canBecomeFirstResponder
    }
}

extension CodeBlockView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        actionHandler?.becomeFirstResponder()
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        actionHandler?.textDidChange(textView)
 
        if textView.isLayoutNeeded {
            actionHandler?.textBlockSetNeedsLayout()
        }
    }
}

private extension UIUserInterfaceStyle {
    var themeName: String {
        switch self {
        case .dark:
            return "gruvbox-dark"
        default:
            return "github-gist"
        }
    }
}

private extension Highlightr {
    static let shared = Highlightr()!
}

