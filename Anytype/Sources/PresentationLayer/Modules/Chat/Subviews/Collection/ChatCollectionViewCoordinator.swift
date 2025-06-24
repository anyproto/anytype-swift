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
    private let visibleRangeThreshold: CGFloat = 10
    private let bigDistanceFromTheBottomThreshold: CGFloat = 30
    private var canCallScrollToTop = false
    private var canCallScrollToBottom = false
    private var scrollToTopUpdateTask: AnyCancellable?
    private var scrollToBottomUpdateTask: AnyCancellable?
    private var sections: [Section] = []
    private var dataSourceApplyTransaction = false
    private var oldVisibleRange: [String] = []
    private var oldIsBigDistance = false
    private var dismissWorkItems: [DispatchWorkItem] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section.ID, Item>?
    // From iOS 17.4 replace to collectionView.isScrollAnimating
    private var isProgrammaticAnimatedScroll = false
    
    var scrollToTop: (() async -> Void)?
    var scrollToBottom: (() async -> Void)?
    var decelerating = false
    var lastScrollProxy: ChatCollectionScrollProxy?
    var itemBuilder: ((Item) -> DataView)?
    var headerBuilder: ((Section.Header) -> HeaderView)?
    var handleVisibleRange: ((_ from: Item, _ to: Item) -> Void)?
    var handleBigDistanceToTheBottom: ((_ isBigDistance: Bool) -> Void)?
    var onTapCollectionBackground: (() -> Void)?
    
    func setupDataSource(collectionView: UICollectionView) {
        let sectionRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(elementKind: UICollectionView.elementKindSectionHeader)
        { [weak self] view, _, indexPath in
            guard let header = self?.sections[safe: indexPath.section]?.header else { return }
            view.contentConfiguration = UIHostingConfiguration {
                self?.headerBuilder?(header)
            }
            .margins(.all, 0)
            view.layer.zPosition = 1
        }
        
        let itemRegistration = UICollectionView.CellRegistration<ChatContainerCell<Item, DataView>, Item> { [weak self] cell, indexPath, item in
            cell.setItem(item, builder: self?.itemBuilder)
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
    
    func setupDismissKeyboardOnTap(collectionView: UICollectionView) {
        collectionView.addTapGesture { [weak self] _ in
            self?.onTapCollectionBackground?()
        }
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
        let oldIsNearBottom = (collectionView.bottomOffset.y - collectionView.contentOffset.y) < bigDistanceFromTheBottomThreshold
        
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
            
            if !isProgrammaticAnimatedScroll {
                updateStateAfterTransaction(collectionView: collectionView)
            }
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
        
        if let collectionView = scrollView as? UICollectionView, !isProgrammaticAnimatedScroll {
            updateStateAfterTransaction(collectionView: collectionView)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        decelerating = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        decelerating = false
        if let collectionView = scrollView as? UICollectionView {
            updateHeaders(collectionView: collectionView)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            updateHeaders(collectionView: collectionView)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, let collectionView = scrollView as? UICollectionView {
            updateHeaders(collectionView: collectionView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isProgrammaticAnimatedScroll = false
        if let collectionView = scrollView as? UICollectionView {
            updateStateAfterTransaction(collectionView: collectionView)
        }
    }
    
    // MARK: - Private
    
    private func updateVisibleRangeIfNeeded(collectionView: UICollectionView) {
        guard let handleVisibleRange else { return }
        
        let cells = collectionView.visibleCells
        
        var visibleIndexes: [IndexPath] = []
        
        let boundsWithoutInsets = collectionView.bounds.inset(by: collectionView.adjustedContentInset)
        
        for cell in cells {
            let intersection = cell.frame.intersection(boundsWithoutInsets)
            if intersection.height > visibleRangeThreshold, let indexPath = collectionView.indexPath(for: cell) {
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
    
    private func updateDistanceFromTheBottom(collectionView: UICollectionView) {
        guard let handleBigDistanceToTheBottom else { return }
        
        let value = (collectionView.bottomOffset.y - collectionView.contentOffset.y) > bigDistanceFromTheBottomThreshold
        guard oldIsBigDistance != value else { return }
        
        oldIsBigDistance = value
        handleBigDistanceToTheBottom(value)
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
            isProgrammaticAnimatedScroll = animated
            collectionView.scrollToItem(at: indexPath, at: position, animated: animated)
            return true
        }
        return false
    }
    
    private func scrollToBottom(collectionView: UICollectionView) {
        if collectionView.bottomOffset != collectionView.contentOffset {
            isProgrammaticAnimatedScroll = true
            collectionView.setContentOffset(collectionView.bottomOffset, animated: true)
        }
    }
    
    private func updateHeaders(collectionView: UICollectionView, animated: Bool = true) {
        let headers = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
        let cells = collectionView.visibleCells
        let visibleBounds = collectionView.bounds.inset(by: collectionView.adjustedContentInset)
        
        dismissWorkItems.forEach { $0.cancel() }
        dismissWorkItems.removeAll()
        
        for header in headers {
            guard let header = header as? UICollectionViewCell else { continue }
            
            let insideSafeArea = header.frame.intersects(visibleBounds)
            
            let intersectionHeight = cells.reduce(0) { $0 + $1.frame.intersection(header.frame).height }
            let overCell = intersectionHeight > header.frame.height * 0.5
            
            let interactive = collectionView.isDragging || collectionView.isDecelerating
            
            if !insideSafeArea {
                // Outside visible area. Show
                updateContentAlpha(cell: header, show: true, animated: animated)
            } else if !overCell {
                // Normal position in list. Show
                updateContentAlpha(cell: header, show: true, animated: animated)
            } else if interactive {
                // Over cell and interactive. Show
                updateContentAlpha(cell: header, show: true, animated: animated)
            } else {
                // Over cell and not interactive. Hidden
                updateContentAlpha(cell: header, show: false, animated: animated)
            }
        }
    }
    
    private func updateContentAlpha(cell: UICollectionViewCell, show: Bool, animated: Bool) {
        let alpha = show ? 1.0 : 0.0
        if cell.contentView.alpha != alpha {
            if animated {
                
                if show {
                    UIView.animate(withDuration: 0.3) {
                        cell.contentView.alpha = alpha
                    }
                } else {
                    let workItem = DispatchWorkItem {
                        UIView.animate(withDuration: 0.3) {
                            cell.contentView.alpha = alpha
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
                    dismissWorkItems.append(workItem)
                }
            } else {
                cell.contentView.alpha = alpha
            }
        }
    }
    
    private func updateStateAfterTransaction(collectionView: UICollectionView) {
        updateVisibleRangeIfNeeded(collectionView: collectionView)
        updateDistanceFromTheBottom(collectionView: collectionView)
        updateHeaders(collectionView: collectionView, animated: false)
    }
}
