import UIKit
import BlocksModels


final class ButtonWithImage: UIControl, CustomizableHitTestAreaView {
    typealias ActionHandler = (_ action: UIAction) -> Void
    
    private var borderEdges: UIRectEdge?
    private var borderWidth: CGFloat = 0.0
    private var borderColor: UIColor = .clear

    private(set) var label: UILabel = .init()
    private(set) var imageView: UIImageView = .init()
    private let containerView = UIStackView()
    private var backgroundColorsMap = [UInt: UIColor]()
    private var imageTintColorsMap = [UInt: UIColor]()
    private var textColorsMap = [UInt: UIColor]()

    var minHitTestArea: CGSize = .zero

    // MARK: - Lifecycle

    init() {
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

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        if let borderEdges = borderEdges {
            privateAddBorders(edges: borderEdges, width: borderWidth, color: borderColor)
        }
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
    }

    private func updateTextColor() {
        guard let color = textColorsMap[state.rawValue] else { return }
        label.textColor = color
    }
    
    private func updateBackgroundColor() {
        guard let color = backgroundColorsMap[state.rawValue] else { return }
        backgroundColor = color
    }
    
    private func updateImageTintColor() {
        guard let color = imageTintColorsMap[state.rawValue] else { return }
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

        label.font = .uxCalloutRegular
        label.isHidden = true
        label.textColor = UIColor.Text.uiColor(from: MiddlewareColor.grey)
        label.isUserInteractionEnabled = false
        label.textAlignment = .center

        addSubview(containerView)
        containerView.edgesToSuperview()
    }

    private func privateAddBorders(edges: UIRectEdge, width: CGFloat, color: UIColor) {
        func addBorder(origin: CGPoint, size: CGSize) {
            let border = CALayer()
            border.frame = .init(origin: origin, size: size)
            border.backgroundColor = color.cgColor
            layer.addSublayer(border)
        }

        if edges.contains(.bottom) || edges == .all {
            let origin = CGPoint(x: bounds.minX, y: bounds.maxY - width)
            let size = CGSize(width: bounds.width, height: width)
            addBorder(origin: origin, size: size)
        }
        if edges.contains(.left) || edges == .all {
            let origin = CGPoint(x: bounds.minX + width, y: bounds.minY)
            let size = CGSize(width: width, height: bounds.height)
            addBorder(origin: origin, size: size)
        }
        if edges.contains(.right) || edges == .all {
            let origin = CGPoint(x: bounds.maxX - width, y: bounds.minY)
            let size = CGSize(width: width, height: bounds.height)
            addBorder(origin: origin, size: size)
        }
        if edges.contains(.top) || edges == .all {
            let origin = CGPoint(x: bounds.minX, y: bounds.minY + width )
            let size = CGSize(width: bounds.width, height: width)
            addBorder(origin: origin, size: size)
        }
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

    func setImageTintColor(_ color: UIColor?, state: UIControl.State) {
        imageTintColorsMap[state.rawValue] = color
        updateColors()
    }

    func setTextColor(_ textColor: UIColor?, state: UIControl.State) {
        textColorsMap[state.rawValue] = textColor
        updateColors()
    }

    @discardableResult func addBorders(edges: UIRectEdge, width: CGFloat, color: UIColor) -> Self {
        borderEdges = edges
        borderWidth = width
        borderColor = color
        return self
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
