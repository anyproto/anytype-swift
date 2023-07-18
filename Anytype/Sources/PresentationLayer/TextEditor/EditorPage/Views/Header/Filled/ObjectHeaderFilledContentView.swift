import UIKit
import Combine
import ShimmerSwift

final class ObjectHeaderFilledContentView: UIView, BlockContentView {
        
    // MARK: - Views
    private let shimmeringView = ShimmeringView(frame: .zero)
    private var headerView = ObjectHeaderView(frame: .zero)
    
    // MARK: - Sizes&SwiftUI intristicSize
    private var sizeConfiguration: HeaderViewSizeConfiguration?
    private var intristicSize: CGSize = .zero
    override var intrinsicContentSize: CGSize { intristicSize }
    
    // MARK: - Private variables
    
    private var subscription: AnyCancellable?
    
    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupLayout()
    }

    // MARK: - BlockContentView
    func update(with configuration: ObjectHeaderFilledConfiguration) {
        sizeConfiguration = configuration.sizeConfiguration
        
        UIView.performWithoutAnimation {
            shimmeringView.isShimmering = configuration.isShimmering
        }
        headerView.configure(
            model: ObjectHeaderView.Model(
                state: configuration.state,
                sizeConfiguration: configuration.sizeConfiguration,
                isShimmering: configuration.isShimmering
            )
        )
        updateIntristicSize()

        guard configuration.state.hasCover else {
            subscription = nil
            return
        }

        subscription = NotificationCenter.Publisher(
            center: .default,
            name: .editorCollectionContentOffsetChangeNotification,
            object: nil
        )
        .compactMap { $0.object as? CGFloat }
        .receiveOnMain()
        .sink { [weak self] in
            self?.updateCoverTransform($0)
        }
    }

    func update(with state: UICellConfigurationState) {
        isUserInteractionEnabled = !state.isLocked
    }
    
    private func updateIntristicSize() {
        intristicSize = systemLayoutSizeFitting(
            CGSize(width: sizeConfiguration?.width ?? 0, height: .greatestFiniteMagnitude),
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .fittingSizeLevel
        )
        invalidateIntrinsicContentSize()
    }
}

private extension ObjectHeaderFilledContentView  {
    
    func setupLayout() {
        addSubview(shimmeringView) {
            $0.pinToSuperview()
        }

        shimmeringView.contentView = headerView
        
        headerView.layoutUsing.anchors {
            $0.pinToSuperview()
        }

        shimmeringView.shimmerSpeed = 120
    }

    func updateCoverTransform(_ offset: CGFloat) {
        let offset = offset

        guard offset.isLess(than: CGFloat.zero) else {
            headerView.applyCoverTransform(.identity)
            return
        }

        let coverHeight = sizeConfiguration?.coverHeight ?? 0
        let scaleY = (abs(offset) + coverHeight) / coverHeight

        var t = CGAffineTransform.identity
        t = t.scaledBy(x: scaleY, y: scaleY)

        headerView.applyCoverTransform(t)
    }
}
