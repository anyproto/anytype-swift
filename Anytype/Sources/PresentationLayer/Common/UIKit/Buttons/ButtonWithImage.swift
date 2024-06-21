import UIKit
import Services


final class ButtonWithImage: UIControl, CustomizableHitTestAreaView {
    enum TextStyle {
        case `default`
        case body
        
        var font: UIFont {
            switch self {
            case .default: return .uxCalloutRegular
            case .body: return .uxBodyRegular
            }
        }
    }
    
    private let defaultState = UIControl.State.normal.rawValue
    private let textStyle: TextStyle
    
    typealias ActionHandler = (_ action: UIAction) -> Void
    
    private(set) var label: UILabel = .init()
    private(set) var imageView: UIImageView = .init()
    private let containerView = UIStackView()
    private var backgroundColorsMap = [UInt: UIColor]()
    private var foregroundColorsMap = [UInt: UIColor]()
    private var imageTintColorsMap = [UInt: UIColor]()
    private var textColorsMap = [UInt: UIColor]()

    var minHitTestArea: CGSize = .zero

    // MARK: - Lifecycle

    init(textStyle: ButtonWithImage.TextStyle = .default) {
        self.textStyle = textStyle
        
        super.init(frame: .zero)

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overriden methods

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return containsCustomHitTestArea(point) ? self : nil
    }
    
    override var intrinsicContentSize: CGSize {
        let labelSize = label.intrinsicContentSize
        let imageViewSize = imageView.intrinsicContentSize
        let spacing: CGFloat = containerView.spacing
        return .init(width: labelSize.width + imageViewSize.width + spacing, height: labelSize.height + imageViewSize.height)
    }

    override var isSelected: Bool {
        didSet {
            updateColors()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateColors()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateColors()
        }
    }
    
    // MARK: - Private methods
    
    private func updateColors() {
        updateTextColor()
        updateBackgroundColor()
        updateImageTintColor()
        updateForegroundColor()
    }

    private func updateTextColor() {
        guard let color = textColorsMap[state.rawValue] ?? textColorsMap[defaultState] else { return }
        label.textColor = color
    }
    
    private func updateBackgroundColor() {
        guard let color = backgroundColorsMap[state.rawValue] ?? backgroundColorsMap[defaultState] else { return }
        backgroundColor = color
    }
    
    private func updateForegroundColor() {
        guard let color = foregroundColorsMap[state.rawValue] ?? foregroundColorsMap[defaultState] else { return }
        containerView.backgroundColor = color
    }
    
    private func updateImageTintColor() {
        guard let color = imageTintColorsMap[state.rawValue] ?? imageTintColorsMap[defaultState] else { return }
        imageView.tintColor = color
    }

    private func setupViews() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.distribution = .fillProportionally
        containerView.axis = .horizontal
        containerView.spacing = 4.0
        containerView.alignment = .center
        containerView.addArrangedSubview(label)
        containerView.addArrangedSubview(imageView)
        containerView.isUserInteractionEnabled = false

        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = false

        label.font = textStyle.font
        label.isHidden = true
        label.textColor = UIColor.Dark.uiColor(from: MiddlewareColor.grey)
        label.isUserInteractionEnabled = false
        label.textAlignment = .center

        addSubview(containerView)
        containerView.edgesToSuperview()
    }

    // MARK: - Public methods

    func addAction(actionHandler: @escaping ActionHandler) {
        let action = UIAction { action in
            actionHandler(action)
        }
        addAction(action, for: .touchUpInside)
    }

    func setBackgroundColor(_ backgroundColor: UIColor?, state: UIControl.State) {
        backgroundColorsMap[state.rawValue] = backgroundColor
        updateColors()
    }
    
    func setForegroundColor(_ foregroundColor: UIColor?, state: UIControl.State) {
        foregroundColorsMap[state.rawValue] = foregroundColor
        updateColors()
    }

    func setImageTintColor(_ color: UIColor?, state: UIControl.State) {
        imageTintColorsMap[state.rawValue] = color
        updateColors()
    }

    func setTextColor(_ textColor: UIColor?, state: UIControl.State) {
        textColorsMap[state.rawValue] = textColor
        updateColors()
    }
    
    func setText(_ text: String) {
        label.isHidden = text.isEmpty
        label.text = text
    }

    func setImage(_ image: UIImage?) {
        imageView.isHidden = image.isNil
        imageView.image = image
    }

    func setMinHitTestArea(_ size: CGSize) {
        minHitTestArea = size
    }
}
