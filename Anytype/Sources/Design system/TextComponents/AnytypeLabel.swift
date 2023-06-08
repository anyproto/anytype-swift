import UIKit


class AnytypeLabel: UIView {
    private var topLabelConstraint: NSLayoutConstraint?
    private var bottomLabelConstraint: NSLayoutConstraint?

    private lazy var anytypeText: UIKitAnytypeText = .init(text: "", style: style, lineBreakModel: .byTruncatingTail)
    private let label: UILabel = .init()
    private var style: AnytypeFont = .bodyRegular

    var textAlignment: NSTextAlignment {
        set {
            label.textAlignment = newValue
        }
        get {
            label.textAlignment
        }
    }

    var textColor: UIColor {
        set {
            label.textColor = newValue
        }
        get {
            label.textColor
        }
    }

    var numberOfLines: Int {
        set {
            label.numberOfLines = newValue
        }
        get {
            label.numberOfLines
        }
    }

    // MARK: - Life cycle

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(style: AnytypeFont) {
        self.style = style

        super.init(frame: .zero)

        setupView()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height + anytypeText.verticalSpacing * 2)
    }

    // MARK: - Setup view

    private func setupView() {
        addSubview(label) {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            topLabelConstraint = $0.top.equal(to: topAnchor, constant: anytypeText.verticalSpacing)
            bottomLabelConstraint = $0.bottom.equal(to: bottomAnchor, constant: -anytypeText.verticalSpacing)
        }
    }

    private func updateLabel() {
        label.attributedText = anytypeText.attrString
        topLabelConstraint?.constant = anytypeText.verticalSpacing
        bottomLabelConstraint?.constant = -anytypeText.verticalSpacing
    }

    // MARK: - Public methods

    func setLineBreakMode(_ lineBreakMode: NSLineBreakMode) {
        label.lineBreakMode = lineBreakMode
        anytypeText = UIKitAnytypeText(
            attributedString: anytypeText.attrString,
            style: anytypeText.anytypeFont,
            lineBreakModel: label.lineBreakMode
        )
        updateLabel()
    }

    func setText(_ text: String, style: AnytypeFont) {
        self.style = style
        anytypeText = UIKitAnytypeText(text: text, style: style, lineBreakModel: label.lineBreakMode)
        updateLabel()
    }

    func setText(_ text: NSAttributedString, style: AnytypeFont) {
        self.style = style
        anytypeText = UIKitAnytypeText(attributedString: text, style: style, lineBreakModel: label.lineBreakMode)
        updateLabel()
    }

    func setText(_ text: NSAttributedString) {
        setText(text, style: style)
    }

    func setText(_ text: String) {
        setText(text, style: style)
    }

    func setText(_ text: UIKitAnytypeText) {
        anytypeText = text
        updateLabel()
    }
}
