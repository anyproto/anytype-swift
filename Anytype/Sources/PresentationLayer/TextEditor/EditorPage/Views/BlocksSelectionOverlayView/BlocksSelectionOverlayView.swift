import UIKit
import SwiftUI
import Combine

final class BlocksSelectionOverlayView: UIView {

    let viewModel: BlocksSelectionOverlayViewModel

    // MARK: - UI elements
    private let blocksOptionView: SelectionOptionsView
    private let simpleTablesOptionView: SimpleTableMenuView

    private lazy var shadowedBlocksOptionView = RoundedShadowView(view: blocksOptionView.asUIView(), cornerRadius: 16)
    private lazy var shadowedSimpleTablesOptionView = RoundedShadowView(view: simpleTablesOptionView.asUIView(), cornerRadius: 16)

    private lazy var movingButtonsView: TwoStandardButtonsView = makeMovingButtonsView()
    private lazy var movingButtonsUIView: UIView = movingButtonsView.asUIView()
    private lazy var statusBarOverlayView = UIView()

    private var cancellables = [AnyCancellable]()

    init(
        viewModel: BlocksSelectionOverlayViewModel,
        blocksOptionView: SelectionOptionsView,
        simpleTablesOptionView: SimpleTableMenuView
    ) {
        self.viewModel = viewModel
        self.blocksOptionView = blocksOptionView
        self.simpleTablesOptionView = simpleTablesOptionView

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
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyShadow()
        }
       
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

        statusBarOverlayView.backgroundColor = .Background.primary

        addSubview(shadowedBlocksOptionView) {
            $0.pinToSuperview(excluding: [.top, .bottom], insets: .init(top: 0, left: 10, bottom: 0, right: 10))
            $0.bottom.equal(to: safeAreaLayoutGuide.bottomAnchor, constant: -10)
            $0.height.equal(to: 100)
        }

        addSubview(shadowedSimpleTablesOptionView) {
            $0.pinToSuperview(excluding: [.top, .bottom], insets: .init(top: 0, left: 10, bottom: 0, right: 10))
            $0.bottom.equal(to: safeAreaLayoutGuide.bottomAnchor, constant: -20)
            $0.height.equal(to: 174)
        }

        addSubview(movingButtonsUIView) {
            $0.pinToSuperview(excluding: [.top], insets: .zero)
        }

        applyShadow()
    }

    private func applyShadow() {
        [shadowedBlocksOptionView, shadowedSimpleTablesOptionView].forEach {
            $0.shadowLayer.fillColor = UIColor.Shadow.primary.cgColor
            $0.shadowLayer.shadowOffset = .init(width: 0, height: 0)
            $0.shadowLayer.shadowOpacity = 1
            $0.shadowLayer.shadowRadius = 40
        }
    }

    private func makeMovingButtonsView() -> TwoStandardButtonsView {
        TwoStandardButtonsView(
            leftButtonData: StandardButtonModel(
                text: Loc.cancel,
                style: .secondaryLarge,
                action: { [weak viewModel] in
                    viewModel?.cancelButtonHandler?()
                }
            ),
            rightButtonData: StandardButtonModel(
                text: Loc.move,
                style: .primaryLarge,
                action: { [weak viewModel] in
                    viewModel?.moveButtonHandler?()
                }
            )
        )
    }
    
    private func bindActions() {
        viewModel.$state.sink { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .hidden:
                self.isHidden = true
                return
            case .moving:
                self.movingButtonsUIView.isHidden = false
                self.shadowedSimpleTablesOptionView.isHidden = true
                self.shadowedBlocksOptionView.isHidden = true
            case let .simpleTableMenu(_, model):
                self.movingButtonsUIView.isHidden = true
                self.shadowedBlocksOptionView.isHidden = true
                self.shadowedSimpleTablesOptionView.isHidden = false
                self.simpleTablesOptionView.viewModel.update(with: model)
            case let .editorMenu(selectedBlocksCount):
                self.movingButtonsUIView.isHidden = true
                self.shadowedSimpleTablesOptionView.isHidden = true
                self.shadowedBlocksOptionView.isHidden = selectedBlocksCount == 0
                return
            }

            self.isHidden = false
        }.store(in: &cancellables)
    }
}
