import UIKit
import AnytypeCore

@MainActor
class UIPhraseTextView: UITextView, UITextViewDelegate {
    
    var textDidChange: ((String) -> Void)?
    var noninteractive = false
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Loc.Auth.LoginFlow.Textfield.placeholder
        label.textColor = UIColor.Text.primary
        label.font = self.font
        label.textAlignment = self.textAlignment
        label.numberOfLines = 0
        label.layer.opacity = 0.3
        return label
    }()

    override init(
        frame: CGRect,
        textContainer: NSTextContainer?
    ) {
        super.init(frame: frame, textContainer: textContainer)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: max(newSize.width, fixedWidth), height: max(newSize.height.rounded(), 151))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if noninteractive, !bounds.size.equalTo(intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var superRect = super.caretRect(for: position)
        guard let font = self.font else { return superRect }

        superRect.size.height = font.pointSize - font.descender
        return superRect
    }
    
    private func setup() {
        delegate = self
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        autocorrectionType = .no
        autocapitalizationType = .none
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        font = AnytypeFont.authInput.uiKitFont
        textColor = UIColor.Auth.inputText
        tintColor = UIColor.Auth.inputText
        textContainer.lineFragmentPadding = 0.0
        backgroundColor = UIColor.Shape.transperentSecondary.withAlphaComponent(0.14)
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        textContentType = .password
        textContainerInset = UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
        
        // add placeholderLabel
        addSubview(placeholderLabel)
        placeholderLabel.layoutUsing.anchors {
            $0.pinToSuperview(insets: textContainerInset)
            $0.width.equal(to: widthAnchor).priority = .defaultHigh - 1
        }
        placeholderLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
    }
    
    func update(with text: String, alignToCenter: Bool, hidden: Bool) {
        attributedText = configureAttributedString(from: text, hidden: hidden)
        handlePlaceholder(text.isNotEmpty)
        handleTextAlignment(alignToCenter: alignToCenter)
        setNeedsLayout()
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        textDidChange?(textView.text)
        handlePlaceholder(textView.text.isNotEmpty)
        setNeedsLayout()
    }
    
    // MARK: - Private
    
    private func handlePlaceholder(_ hide: Bool) {
        placeholderLabel.isHidden = hide
    }
    
    private func handleTextAlignment(alignToCenter: Bool) {
        textAlignment = alignToCenter ? .center : .natural
    }
}

extension UIPhraseTextView {
    private static let colors: [UIColor] = [
        .System.yellow, .System.red, .System.pink, .System.purple, .System.blue, .System.sky, .System.green
    ]
    
    private func configureAttributedString(from text: String, hidden: Bool) -> NSAttributedString {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = AnytypeFont.authInput.config.lineHeight
        var attributes = [
            NSAttributedString.Key.paragraphStyle : style,
            NSAttributedString.Key.font: AnytypeFont.authInput.uiKitFont,
            NSAttributedString.Key.foregroundColor: UIColor.Auth.inputText
        ]
        
        let words = text.components(separatedBy: " ")
        
        let attributedWords: [NSAttributedString]
        if FeatureFlags.disableColorfulSeedPhrase {
            let color = UIColor.Control.white
            attributedWords = words.map { word in
                attributes[NSAttributedString.Key.foregroundColor] = color
                attributes[NSAttributedString.Key.backgroundColor] = hidden ? color : nil
                return NSAttributedString(string: word, attributes: attributes)
            }
        } else {
            let colors = Self.colors + Self.colors
            attributedWords = zip(words, colors).map { (word, color) in
                attributes[NSAttributedString.Key.foregroundColor] = color
                attributes[NSAttributedString.Key.backgroundColor] = hidden ? color : nil
                return NSAttributedString(string: word, attributes: attributes)
            }
        }
        
        // hack to increase words spacing when view is noninteractive
        let separator = noninteractive ? "     " : " "
        return attributedWords.joined(with: separator)
    }
}
