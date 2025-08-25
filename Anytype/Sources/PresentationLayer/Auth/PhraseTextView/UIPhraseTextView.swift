import UIKit
import AnytypeCore

@MainActor
class UIPhraseTextView: UITextView, UITextViewDelegate {
    
    var textDidChange: ((String) -> Void)?
    var noninteractive = false
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Loc.Auth.LoginFlow.Textfield.placeholder
        label.textColor = FeatureFlags.brandNewAuthFlow ? UIColor.Text.tertiary : UIColor.Text.primary
        label.font = self.font
        label.textAlignment = self.textAlignment
        label.numberOfLines = 0
        if !FeatureFlags.brandNewAuthFlow {
            label.layer.opacity = 0.3
        }
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
        font = FeatureFlags.brandNewAuthFlow ? AnytypeFont.previewTitle1Medium.uiKitFont : AnytypeFont.authInput.uiKitFont
        tintColor = FeatureFlags.brandNewAuthFlow ? UIColor.Control.accent100 : UIColor.Auth.inputText
        textContainer.lineFragmentPadding = 0.0
        backgroundColor = FeatureFlags.brandNewAuthFlow ? UIColor.Shape.transperentSecondary :  UIColor.Shape.transperentSecondary.withAlphaComponent(0.14)
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
    
    private func configureAttributedString(from text: String, hidden: Bool) -> NSAttributedString {
        
        let foregroundColor = FeatureFlags.brandNewAuthFlow ? UIColor.Text.primary : UIColor.Control.white
        let anytypeFont: AnytypeFont = FeatureFlags.brandNewAuthFlow ? AnytypeFont.previewTitle1Medium : AnytypeFont.authInput
        let style = NSMutableParagraphStyle()
        style.lineSpacing = anytypeFont.config.lineHeight
        let attributes = [
            NSAttributedString.Key.paragraphStyle : style,
            NSAttributedString.Key.font: anytypeFont.uiKitFont,
            NSAttributedString.Key.foregroundColor: foregroundColor,
            NSAttributedString.Key.backgroundColor: hidden ? foregroundColor : UIColor.clear
        ]
        
        let words = text.components(separatedBy: " ")
        let attributedWords = words.map { NSAttributedString(string: $0, attributes: attributes) }
        
        // hack to increase words spacing when view is noninteractive
        let separator = noninteractive ? "     " : " "
        return attributedWords.joined(with: separator)
    }
}
