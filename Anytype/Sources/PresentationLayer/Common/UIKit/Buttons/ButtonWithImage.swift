import UIKit
import BlocksModels

final class ButtonWithImage: UIControl {
    private var borderEdges: UIRectEdge?
    private var borderWidth: CGFloat = 0.0
    private var borderColor: UIColor = .clear

    private(set) var label: UILabel = .init()
    private(set) var imageView: UIImageView = .init()

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        if let borderEdges = borderEdges {
            privateAddBorders(edges: borderEdges, width: borderWidth, color: borderColor)
        }
    }

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.selected : .clear
        }
    }

    private func setupViews() {
        let container = UIStackView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.distribution = .fillProportionally
        container.axis = .horizontal
        container.spacing = 4.0
        container.alignment = .center
        container.addArrangedSubview(label)
        container.addArrangedSubview(imageView)
        container.isUserInteractionEnabled = false

        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = false

        label.font = UIFont.bodyFont
        label.isHidden = true
        label.textColor = MiddlewareColor.grey.color(background: false)
        label.isUserInteractionEnabled = false

        addSubview(container)
        container.edgesToSuperview()
    }

    func addBorders(edges: UIRectEdge, width: CGFloat, color: UIColor) {
        borderEdges = edges
        borderWidth = width
        borderColor = color
    }

    func setText(_ text: String) {
        label.isHidden = text.isEmpty
        label.text = text
    }

    func setImage(_ image: UIImage?) {
        imageView.isHidden = image.isNil
        imageView.image = image
    }

    private func privateAddBorders(edges: UIRectEdge, width: CGFloat, color: UIColor) {
        func addBorder(origin: CGPoint, size: CGSize) {
            let border = CALayer()
            border.frame = .init(origin: origin, size: size)
            border.backgroundColor = color.cgColor
            layer.addSublayer(border)
        }

        if edges == .bottom || edges == .all {
            let origin = CGPoint(x: bounds.minX, y: bounds.maxY)
            let size = CGSize(width: bounds.width, height: width)
            addBorder(origin: origin, size: size)
        }
        if edges == .left || edges == .all {
            let origin = CGPoint(x: bounds.minX, y: bounds.minY)
            let size = CGSize(width: width, height: bounds.height)
            addBorder(origin: origin, size: size)
        }
        if edges == .right || edges == .all {
            let origin = CGPoint(x: bounds.maxX, y: bounds.minY)
            let size = CGSize(width: width, height: bounds.height)
            addBorder(origin: origin, size: size)
        }
        if edges == .top || edges == .all {
            let origin = CGPoint(x: bounds.minX, y: bounds.minY)
            let size = CGSize(width: bounds.width, height: width)
            addBorder(origin: origin, size: size)
        }
    }

}
