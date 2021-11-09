import UIKit
import SwiftUI

protocol BlocksSelectionDelegate: AnyObject {
    func didTapEndSelectionModeButton()

    func didTapDelete()
    func didTapAddBelow()
    func didTapDuplicate()
    func didTapTurnInto()
    func didTapMoveTo()
}

final class BlocksSelectionOverlayView: UIView {
    private lazy var navigationView = SelectionNavigationView(frame: .zero)
    private lazy var blocksOptionView = BlocksOptionView(tapHandler: { _ in } )
    private lazy var statusBarOverlayView = UIView()
    weak var delegate: BlocksSelectionDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let isValid = subviews.contains {
            $0.hitTest(convert(point, to: $0), with: event) != nil
        }

        return isValid
    }

    private func setupView() {
        bindActions()
        backgroundColor = .clear

        addSubview(statusBarOverlayView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.height.equal(to: UIApplication.shared.statusBarFrame.height)
        }

        statusBarOverlayView.backgroundColor = .white

        addSubview(navigationView) {
            $0.pin(to: self, excluding: [.bottom, .top], insets: .zero)
            $0.top.equal(to: statusBarOverlayView.bottomAnchor)
            $0.height.equal(to: 48)
        }


        let blocksOptionUIView = blocksOptionView.asUIView()
        let shadowedBlocksOptionView = RoundedShadowView(view: blocksOptionUIView, cornerRadius: 16)

        addSubview(shadowedBlocksOptionView) {
            $0.pinToSuperview(excluding: [.top], insets: .init(top: 0, left: 10, bottom: -10, right: -10))
            $0.height.equal(to: 100)
        }

        blocksOptionUIView.layer.cornerRadius = 16
        blocksOptionUIView.layer.masksToBounds = true
        shadowedBlocksOptionView.shadowLayer.fillColor = UIColor.white.cgColor
        shadowedBlocksOptionView.shadowLayer.shadowColor = UIColor.black.cgColor
        shadowedBlocksOptionView.shadowLayer.shadowOffset = .init(width: 0, height: 2)
        shadowedBlocksOptionView.shadowLayer.shadowOpacity = 0.25
        shadowedBlocksOptionView.shadowLayer.shadowRadius = 3
    }

    private func bindActions() {
        navigationView.leftButtonTap = { [unowned self] in
            delegate?.didTapEndSelectionModeButton()
        }
    }
}

private final class SelectionNavigationView: UIView {
    var leftButtonTap: (() -> Void)?

    private lazy var titleLabel = UILabel()
    private lazy var leftButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    private func setupView() {
        backgroundColor = .white

        addSubview(titleLabel) {
            $0.centerX.equal(to: centerXAnchor)
            $0.centerY.equal(to: centerYAnchor)
        }

        titleLabel.text = "Awesome new text will be here"

        let leftButtonAction = UIAction(handler: { [unowned self] _ in
            leftButtonTap?()
        })
        leftButton.setTitle("Done".localized, for: .normal)
        leftButton.setTitleColor(.pureAmber, for: .normal)
        leftButton.addAction(leftButtonAction, for: .touchUpInside)

        addSubview(leftButton) {
            $0.trailing.equal(to: trailingAnchor, constant: -16)
            $0.centerY.equal(to: centerYAnchor)
        }
    }
}

final private class RoundedShadowView<View: UIView>: UIView {
    let view: View
    let shadowLayer: CAShapeLayer
    private let cornerRadius: CGFloat

    init(view: View, cornerRadius: CGFloat) {
        self.view = view
        self.cornerRadius = cornerRadius

        self.shadowLayer = CAShapeLayer()

        shadowLayer.shadowPath = shadowLayer.path

        super.init(frame: view.frame)

        setupLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shadowLayer.frame = view.frame

        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    private func setupLayout() {
        layer.insertSublayer(shadowLayer, at: 0)

        addSubview(view) {
            $0.pinToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
