import UIKit
import Combine
import AnytypeCore

final class DividerCursorController {
    var isMovingModeEnabled = false {
        didSet {
            isMovingModeEnabled ? placeDividerCursor() : moveCursorView.removeFromSuperview()
        }
    }

    private let collectionView: UICollectionView
    private let view: UIView
    private let movingManager: EditorPageBlocksStateManagerProtocol
    private var cancellables = [AnyCancellable]()
    private var lastIndexPath: IndexPath?

    lazy var moveCursorView: UIView = {
        let view = UIView()
        view.backgroundColor = AnytypeColor.pureAmber.asUIColor
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true

        view.frame = .init(
            origin: .init(x: 8, y: 0),
            size: CGSize(width: self.view.bounds.size.width - 16, height: 4)
        )

        return view
    }()

    init(
        movingManager: EditorPageBlocksStateManagerProtocol,
        view: UIView,
        collectionView: UICollectionView
    ) {
        self.movingManager = movingManager
        self.view = view
        self.collectionView = collectionView

        setupSubscription()
    }

    private func setupSubscription() {
        NotificationCenter.Publisher(
            center: .default,
            name: .editorCollectionContentOffsetChangeNotification,
            object: nil
        )
            .compactMap { $0.object as? CGFloat }
            .receiveOnMain()
            .sink { [weak self] in self?.handleScrollUpdate(offset: $0) }
            .store(in: &cancellables)
    }

    private func handleScrollUpdate(offset: CGFloat) {
        guard isMovingModeEnabled else { return }

        adjustDividerCursorPosition()
    }

    private func placeDividerCursor() {
        guard moveCursorView.superview == nil else {
            anytypeAssertionFailure("Unexpected case", domain: .editorPage)
            return
        }

        view.addSubview(moveCursorView)
        adjustDividerCursorPosition()
    }

    private func adjustDividerCursorPosition() {
        let point = collectionView.convert(view.center, from: view)

        guard let indexPath = collectionView.indexPathForItem(at: point),
              let cell = collectionView.cellForItem(at: indexPath) else {
                  lastIndexPath.map(adjustDivider(at:))
                  return
              }

        let cellPoint = cell.convert(view.center, from: view)
        let cellMidY = cell.bounds.midY
        let isPointAboveMidY = cellPoint.y < cellMidY

        var supposedInsertIndexPath = isPointAboveMidY
                                        ? indexPath
                                        : IndexPath(row: indexPath.row + 1, section: indexPath.section)

        if !movingManager.canPlaceDividerAtIndexPath(supposedInsertIndexPath) {
            if let lastIndexPath = lastIndexPath {
                supposedInsertIndexPath = lastIndexPath
            } else {
                return
            }
        }

        if lastIndexPath != supposedInsertIndexPath {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        lastIndexPath = supposedInsertIndexPath

        adjustDivider(at: supposedInsertIndexPath)
    }

    private func adjustDivider(at indexPath: IndexPath) {
        let newOrigin: CGFloat

        if let cell = collectionView.cellForItem(at: indexPath) {
            let convertedCellOrigin = view.convert(cell.frame.origin, from: collectionView)
            newOrigin = convertedCellOrigin.y - 2
        } else if let cell = collectionView.cellForItem(
            at: IndexPath(row: indexPath.row - 1, section: indexPath.section)
        ) {
            let convertedCellOrigin = view.convert(cell.frame.origin, from: collectionView)
            newOrigin = cell.frame.height + convertedCellOrigin.y - 2
        } else {
            anytypeAssertionFailure("unexpected case for adjusting divider", domain: .editorPage)
            return
        }

        var previousFrame = moveCursorView.frame

        previousFrame.origin.y = newOrigin
        moveCursorView.frame = previousFrame
    }
}
