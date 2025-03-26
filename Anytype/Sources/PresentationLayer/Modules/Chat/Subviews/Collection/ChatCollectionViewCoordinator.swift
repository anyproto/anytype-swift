import Foundation
import SwiftUI
import Combine
import UIKit

final class ChatCollectionViewCoordinator<
    Section: Hashable & ChatCollectionSection & Identifiable & Sendable,
    Item: Hashable & Identifiable & Sendable,
    DataView: View,
    HeaderView: View>: NSObject, UICollectionViewDelegate where Item.ID == String, Section.Item == Item, Section.ID: Sendable {
    
    private let distanceForLoadNextPage: CGFloat = 300
    private let visibleDelta: CGFloat = 10
    private var canCallScrollToTop = false
    private var canCallScrollToBottom = false
    private var scrollToTopUpdateTask: AnyCancellable?
    private var scrollToBottomUpdateTask: AnyCancellable?
    private var sections: [Section] = []
    private var dataSourceApplyTransaction = false
    private var oldVisibleRange: [String] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section.ID, Item>?
    private weak var collectionView: UICollectionView? // SwiftUI view owned
    
    var scrollToTop: (() async -> Void)?
    var scrollToBottom: (() async -> Void)?
    var decelerating = false
    var lastScrollProxy: ChatCollectionScrollProxy?
    var itemBuilder: ((Item) -> DataView)?
    var headerBuilder: ((Section.Header) -> HeaderView)?
    var handleVisibleRange: ((_ from: Item, _ to: Item) -> Void)?
    
    func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.showsSeparators = false
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.interGroupSpacing = 0
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            section.decorationItems = [] // Delete section background
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.pinToVisibleBounds = true
            
            section.boundarySupplementaryItems = [header]
            
//            section.visibleItemsInvalidationHandler = { [weak self] (items, offset, environment) in
//                guard let collectionView = self?.collectionView else { return }
//                for item in items {
//                    guard item.representedElementKind == UICollectionView.elementKindSectionHeader else { continue }
////                    print("top \(environment.container.contentInsets.top)")
//                    print("\(item.frame.minY), \((offset.y - collectionView.topOffset.y))")
//                    let offsetY = offset.y - collectionView.topOffset.y
//                    let isPinned = abs(item.frame.minY - offsetY) < 2
//                    print("is pinned \(isPinned)")
//                    print("Z index \(item.zIndex)")
//                    
//                    let view = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: item.indexPath)
//                    
//                    guard let cell = view as? UICollectionViewCell else { continue }
//                    
////                    print("minY \(item.frame.minY), offset \(offset.y), goodOffset: \(self.collectionView?.topOffset.y)")
//                    if isPinned && !collectionView.isDragging && !collectionView.isDecelerating {
//                        // если пользователь скроллит — показываем
//                        // если скролл остановился — скрываем
////                        item.transform = CGAffineTransform(scaleX: 1.0, y: 0.2)
//                        cell.contentView.alpha = 0.0
//                    } else {
//                        cell.contentView.alpha = 1.0
//                        // если секция на своём месте — всегда показываем
////                        item.transform = CGAffineTransform(scaleX: 1.0, y: 0.2)
//                    }
//                }
//            }
            
            return section
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        collectionView.showsVerticalScrollIndicator = false
        
        if #available(iOS 16.4, *) {
            collectionView.keyboardDismissMode = .interactive
        } else {
            // Safe area regions can be disabled starting from iOS 16.4.
            // Without disabling safe area regions on iOS 16.0, interactive behavior will not work correctly.
            collectionView.keyboardDismissMode = .onDrag
        }
        
        setupDataSource(collectionView: collectionView)
        self.collectionView = collectionView
        
        return collectionView
    }
    
    // MARK: Update
    
    func updateState(collectionView: UICollectionView, sections: [Section], scrollProxy: ChatCollectionScrollProxy) {
        guard let dataSource, self.sections != sections else {
            appyScrollProxy(collectionView: collectionView, scrollProxy: scrollProxy, fallbackScrollToBottom: false)
            return
        }
        
        var newSnapshot = NSDiffableDataSourceSnapshot<Section.ID, Item>()
        
        for section in sections {
            newSnapshot.appendSections([section.id])
            newSnapshot.appendItems(section.items, toSection: section.id)
        }
        
        var oldVisibleCellAttributes: UICollectionViewLayoutAttributes?
        var visibleItem: Item?
        
        for visibleIndexPath in collectionView.indexPathsForVisibleItems {
            if let attributes = collectionView.layoutAttributesForItem(at: visibleIndexPath),
               let item = dataSource.itemIdentifier(for: visibleIndexPath),
               newSnapshot.indexOfItem(item) != nil {
                visibleItem = item
                oldVisibleCellAttributes = attributes
                break
            }
        }
        
        let oldContentSize = collectionView.contentSize
        let oldContentOffset = collectionView.contentOffset
        let oldIsNearBottom = (collectionView.bottomOffset.y - collectionView.contentOffset.y) < 30
        
        self.sections = sections
        
        CATransaction.begin()
        
        dataSourceApplyTransaction = true
        dataSource.apply(newSnapshot, animatingDifferences: false) { [weak self] in
            guard let self else { return }
            
            // Safe offset for visible cells
            if collectionView.contentSize.height != oldContentSize.height, // If the height has changed
                oldContentSize.height != 0, // If is not first update
                let oldVisibleCellAttributes, // If the old state contains a visible cell that will be used to calculate the difference
                let visibleItem,
                // If the new state contains the same cell
                let visibleIndexPath = dataSource.indexPath(for: visibleItem),
                let visibleCellAttributes = collectionView.layoutAttributesForItem(at: visibleIndexPath)
            {
                let diffY = visibleCellAttributes.frame.minY - oldVisibleCellAttributes.frame.minY
                
                let offsetY = oldContentOffset.y + diffY
                if collectionView.contentOffset.y != offsetY {
                    collectionView.contentOffset.y = offsetY
                }
            }
            
            appyScrollProxy(collectionView: collectionView, scrollProxy: scrollProxy, fallbackScrollToBottom: oldIsNearBottom)
            canCallScrollToTop = true
            canCallScrollToBottom = true
            dataSourceApplyTransaction = false
            CATransaction.commit()
            
            updateVisibleRangeIfNeeded(collectionView: collectionView)
            UpdateHeaders(collectionView: collectionView, animated: false)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !dataSourceApplyTransaction, scrollView.contentSize.height > 0 else { return }
        
        let distanceToTop = scrollView.contentOffset.y - scrollView.topOffset.y
        let distanceToBottom = scrollView.bottomOffset.y - scrollView.contentOffset.y
        
        if distanceForLoadNextPage > distanceToTop {
            if canCallScrollToTop, scrollToTopUpdateTask.isNil {
                canCallScrollToTop = false
                scrollToTopUpdateTask = Task { [weak self] in
                    await self?.scrollToTop?()
                    self?.scrollToTopUpdateTask = nil
                }.cancellable()
            }
        } else if distanceForLoadNextPage > distanceToBottom {
            if canCallScrollToBottom, scrollToBottomUpdateTask.isNil {
                canCallScrollToBottom = false
                scrollToBottomUpdateTask = Task { [weak self] in
                    await self?.scrollToBottom?()
                    self?.scrollToBottomUpdateTask = nil
                }.cancellable()
            }
        }
        
        if let collectionView = scrollView as? UICollectionView {
            updateVisibleRangeIfNeeded(collectionView: collectionView)
            UpdateHeaders(collectionView: collectionView, animated: false)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        decelerating = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        decelerating = false
        if let collectionView = scrollView as? UICollectionView {
            UpdateHeaders(collectionView: collectionView)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            UpdateHeaders(collectionView: collectionView, animated: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, let collectionView = scrollView as? UICollectionView {
            UpdateHeaders(collectionView: collectionView)
        }
    }
    
    // MARK: - Private
    
    private func setupDataSource(collectionView: UICollectionView) {
        let sectionRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(elementKind: UICollectionView.elementKindSectionHeader)
        { [weak self] view, _, indexPath in
            guard let header = self?.sections[safe: indexPath.section]?.header else { return }
            view.contentConfiguration = UIHostingConfiguration {
                self?.headerBuilder?(header)
            }
            .margins(.all, 0)
            view.layer.zPosition = 1
        }
        
        let itemRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [weak self] cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                self?.itemBuilder?(item)
            }
            .margins(.all, 0)
            .minSize(height: 0)
        }
    
        let dataSource = UICollectionViewDiffableDataSource<Section.ID, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueConfiguredReusableCell(using: itemRegistration, for: indexPath, item: item)
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView in
            let cell = collectionView.dequeueConfiguredReusableSupplementary(using: sectionRegistration, for: indexPath)
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
            return cell
        }
        
        self.dataSource = dataSource
    }
    
    private func updateVisibleRangeIfNeeded(collectionView: UICollectionView) {
        guard let handleVisibleRange else { return }
        
        let cells = collectionView.visibleCells
        
        var visibleIndexes: [IndexPath] = []
        
        let boundsWithoutInsets = collectionView.bounds.inset(by: collectionView.adjustedContentInset)
        
        for cell in cells {
            let intersection = cell.frame.intersection(boundsWithoutInsets)
            if (cell.frame.height - intersection.height) < visibleDelta, let indexPath = collectionView.indexPath(for: cell) {
                visibleIndexes.append(indexPath)
            }
        }
        
        visibleIndexes.sort()
        
        if let first = visibleIndexes.first,
           let firstItem = dataSource?.itemIdentifier(for: first),
           let last = visibleIndexes.last,
           let lastItem = dataSource?.itemIdentifier(for: last) {
        
            let newRange = [firstItem.id, lastItem.id]
            if oldVisibleRange != newRange {
                oldVisibleRange = newRange
                handleVisibleRange(firstItem, lastItem)
            }
        }

    }
    
    private func appyScrollProxy(collectionView: UICollectionView, scrollProxy: ChatCollectionScrollProxy, fallbackScrollToBottom: Bool) {
        guard lastScrollProxy != scrollProxy else {
            if fallbackScrollToBottom {
                scrollToBottom(collectionView: collectionView)
            }
            return
        }
        
        switch scrollProxy.scrollOperation {
        case .scrollTo(let itemId, let position, let animated):
            if scrollTo(collectionView: collectionView, itemId: itemId, position: position.collectionViewPosition, animated: animated) {
                lastScrollProxy = scrollProxy
            }
        case .none:
            if fallbackScrollToBottom {
                scrollToBottom(collectionView: collectionView)
            }
            lastScrollProxy = scrollProxy
        }
    }
    
    private func scrollTo(collectionView: UICollectionView, itemId: String, position: UICollectionView.ScrollPosition, animated: Bool) -> Bool {
        guard let dataSource else { return false }
        
        let currentSnapshot = dataSource.snapshot()
        
        if let item = currentSnapshot.itemIdentifiers.first(where: { $0.id == itemId }),
           let indexPath = dataSource.indexPath(for: item) {
            collectionView.scrollToItem(at: indexPath, at: position, animated: animated)
            return true
        }
        return false
    }
    
    private func scrollToBottom(collectionView: UICollectionView) {
        collectionView.setContentOffset(collectionView.bottomOffset, animated: true)
    }
    
    private func UpdateHeaders(collectionView: UICollectionView, animated: Bool = true) {
        let headers = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
        let cells = collectionView.visibleCells
        let visibleBounds = collectionView.bounds.inset(by: UIEdgeInsets(top: collectionView.adjustedContentInset.top, left: 0, bottom: 0, right: 0))
        
        for header in headers {
            guard let header = header as? UICollectionViewCell else { continue }
            
            let insideSafeArea = header.frame.intersects(visibleBounds)
            
            let intersectionHeight = cells.reduce(0) { $0 + $1.frame.intersection(header.frame).height }
            let overCell = intersectionHeight > header.frame.height * 0.5
            
            let interactive = collectionView.isDragging || collectionView.isDecelerating
            
            if !insideSafeArea {
                // Outside visible area. Hidden
                updateContentAlpha(cell: header, alpha: 0.0, animated: animated)
            } else if !overCell {
                // Normal position in list. Show
                updateContentAlpha(cell: header, alpha: 1.0, animated: animated)
            } else if interactive {
                // Over cell and interactive. Show
                updateContentAlpha(cell: header, alpha: 1.0, animated: animated)
            } else {
                // Over cell and not interactive. Hidden
                updateContentAlpha(cell: header, alpha: 0.0, animated: animated)
            }
        }
    }
    
    private func updateContentAlpha(cell: UICollectionViewCell, alpha: CGFloat, animated: Bool) {
        if cell.contentView.alpha != alpha {
            if animated {
                UIView.animate(withDuration: 0.3) {
                    cell.contentView.alpha = alpha
                }
            } else {
                cell.contentView.alpha = alpha
            }
        }
    }
}
