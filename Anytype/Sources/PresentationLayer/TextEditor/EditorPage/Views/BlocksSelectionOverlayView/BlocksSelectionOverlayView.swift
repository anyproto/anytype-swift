import UIKit
import SwiftUI
import Combine

final class BlocksSelectionOverlayView: UIView {

    let viewModel: BlocksSelectionOverlayViewModel

    // MARK: - UI elements
    private let blocksOptionView: BlocksOptionView
    private lazy var shadowedBlocksOptionView = RoundedShadowView(view: blocksOptionView.asUIView(), cornerRadius: 16)
    private lazy var movingButtonsView: TwoStandardButtonsView = makeMovingButtonsView()
    private lazy var movingButtonsUIView: UIView = movingButtonsView.asUIView()
    private lazy var navigationView = SelectionNavigationView(frame: .zero)
    private lazy var statusBarOverlayView = UIView()

    private var blockOptionsViewBottonConstraint: NSLayoutConstraint?

    private var cancellables = [AnyCancellable]()

    init(
        viewModel: BlocksSelectionOverlayViewModel,
        blocksOptionView: BlocksOptionView
    ) {
        self.viewModel = viewModel
        self.blocksOptionView = blocksOptionView

        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("unavailable initializer")
    }

    // MARK: - Override
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        subviews.contains {
            $0.hitTest(convert(point, to: $0), with: event).isNotNil
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyShadow()
    }

    // MARK: - Private
    private func setupView() {
        bindActions()
        backgroundColor = .clear

        let statusBarHeight = UIApplication.shared.mainWindowInsets.top
        addSubview(statusBarOverlayView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.height.equal(to: statusBarHeight)
        }

        statusBarOverlayView.backgroundColor = .backgroundPrimary

        addSubview(navigationView) {
            $0.pin(to: self, excluding: [.bottom, .top], insets: .zero)
            $0.top.equal(to: statusBarOverlayView.bottomAnchor)
            $0.height.equal(to: 48)
        }

        addSubview(shadowedBlocksOptionView) {
            $0.pinToSuperview(excluding: [.top], insets: .init(top: 0, left: 10, bottom: -10, right: -10))
            $0.height.equal(to: 100)
        }

        addSubview(movingButtonsUIView) {
            $0.pinToSuperview(excluding: [.top], insets: .zero)
        }

        applyShadow()
    }

    private func applyShadow() {
        shadowedBlocksOptionView.view.layer.cornerRadius = 16
        shadowedBlocksOptionView.view.layer.masksToBounds = true
        shadowedBlocksOptionView.shadowLayer.fillColor = UIColor.textPrimary.cgColor
        shadowedBlocksOptionView.shadowLayer.shadowOffset = .init(width: 0, height: 2)
        shadowedBlocksOptionView.shadowLayer.shadowOpacity = 0.25
        shadowedBlocksOptionView.shadowLayer.shadowRadius = 3
    }

    private func makeMovingButtonsView() -> TwoStandardButtonsView {
        TwoStandardButtonsView(
            leftButtonData: StandardButtonData(
                text: "Cancel".localized,
                style: .secondary,
                action: { [weak viewModel] in
                    viewModel?.cancelButtonHandler?()
                }
            ),
            rightButtonData: StandardButtonData(
                text: "Move".localized,
                style: .primary,
                action: { [weak viewModel] in
                    viewModel?.moveButtonHandler?()
                }
            )
        )
    }

    private func bindActions() {
        navigationView.leftButtonTap = { [unowned self] in
            viewModel.endEditingModeHandler?()
        }

        viewModel.$navigationTitle.sink { [unowned self] title in
            navigationView.titleLabel.text = title
        }.store(in: &cancellables)

        viewModel.$isBlocksOptionViewVisible.sink { [unowned self] isVisible in
            shadowedBlocksOptionView.isHidden = !isVisible
        }.store(in: &cancellables)

        viewModel.$isMovingButtonsVisible.sink { [unowned self] isVisible in
            movingButtonsUIView.isHidden = !isVisible
            navigationView.leftButton.isHidden = isVisible
        }.store(in: &cancellables)
    }
}

private final class SelectionNavigationView: UIView {
    var leftButtonTap: (() -> Void)?

    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var leftButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    private func setupView() {
        backgroundColor = .backgroundPrimary

        addSubview(titleLabel) {
            $0.centerX.equal(to: centerXAnchor)
            $0.centerY.equal(to: centerYAnchor)
        }

        titleLabel.font = .uxTitle1Semibold

        let leftButtonAction = UIAction(handler: { [unowned self] _ in
            leftButtonTap?()
        })
        leftButton.setTitle("Done".localized, for: .normal)
        leftButton.setTitleColor(UIColor.System.amber, for: .normal)
        leftButton.addAction(leftButtonAction, for: .touchUpInside)

        addSubview(leftButton) {
            $0.trailing.equal(to: trailingAnchor, constant: -16)
            $0.centerY.equal(to: centerYAnchor)
        }
    }
}
