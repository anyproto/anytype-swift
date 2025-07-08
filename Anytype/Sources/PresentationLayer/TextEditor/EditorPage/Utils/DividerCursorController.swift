import UIKit
import Combine
import AnytypeCore

@MainActor
final class DividerCursorController {
    enum MovingMode {
        case none
        case dragNdrop
        case drum
    }

    private enum Constants {
        enum Divider {
            static let cornerRadius = 2.0
            static let origin = CGPoint(x: 8, y: 0)
            static let padding = 8.0
            static let height = 4.0
        }
    }

    var movingMode: MovingMode = .none {
        didSet {
            switch movingMode {
            case .none:
                lastIndexPath = nil
                moveCursorView.removeFromSuperview()
            case .dragNdrop, .drum:
                placeDividerCursor()
            }
        }
    }

    private let collectionView: UICollectionView
    private let view: UIView
    private let movingManager: any EditorPageBlocksStateManagerProtocol
    private var cancellables = [AnyCancellable]()
    private var lastIndexPath: IndexPath?

    lazy var moveCursorView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor.Control.accent100
        view.layer.cornerRadius = Constants.Divider.cornerRadius
        view.layer.masksToBounds = true

        view.frame = .init(
            origin: Constants.Divider.origin,
            size: CGSize(width: self.view.bounds.size.width - Constants.Divider.padding * 2, height: Constants.Divider.height)
        )

        return view
    }()

    init(
        movingManager: any EditorPageBlocksStateManagerProtocol,
        view: UIView,
        collectionView: UICollectionView
    ) {
        self.movingManager = movingManager
        self.view = view
        self.collectionView = collectionView

        setupSubscription()
    }

    func adjustDivider(at point: CGPoint) {
        adjustDividerCursorPosition(at: point)
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
            return
        }

        var previousFrame = moveCursorView.frame

        previousFrame.origin.y = newOrigin
        moveCursorView.frame = previousFrame
        moveCursorView.isHidden = false
        
        lastIndexPath = indexPath
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
        switch movingMode {
        case .none:
            return
        case .dragNdrop:
            break
        case .drum:
            let point = collectionView.convert(view.center, from: view)
            adjustDividerCursorPosition(at: point)
        }
    }

    private func placeDividerCursor() {
        guard moveCursorView.superview == nil else { return }

        view.addSubview(moveCursorView)
        let point = collectionView.convert(view.center, from: view)
        adjustDividerCursorPosition(at: point)
    }

    private func adjustDividerCursorPosition(at point: CGPoint) {
        guard let indexPath = collectionView.indexPathForItem(at: point),
              let cell = collectionView.cellForItem(at: indexPath) else {
                  lastIndexPath.map(adjustDivider(at:))
                  return
              }

        let cellPoint = cell.convert(point, from: collectionView)
        let cellMidY = cell.bounds.midY
        let isPointAboveMidY = cellPoint.y < cellMidY

        let cellPointPercentage = cellPoint.y / cell.bounds.size.height

        if 0.33...0.66 ~= cellPointPercentage,
           movingManager.canMoveItemsToObject(at: indexPath) {
            objectSelectionState(at: indexPath)
            return
        }

        collectionView.deselectAllSelectedItems(animated: false)

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

        adjustDivider(at: supposedInsertIndexPath)
    }

    private func objectSelectionState(at indexPath: IndexPath) {
        moveCursorView.isHidden = true

        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
    }
}
