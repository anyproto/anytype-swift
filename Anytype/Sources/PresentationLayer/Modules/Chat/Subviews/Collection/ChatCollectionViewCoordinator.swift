import Foundation
import SwiftUI
import Combine
import UIKit

final class ChatCollectionViewCoordinator<Section: Hashable, Item: Hashable & Identifiable, DataView: View>: NSObject, UICollectionViewDelegate where Item.ID == String {
    
    private let distanceForLoadNextPage: CGFloat = 50
    private var canCallScrollToBottom = false
    private var scrollUpdateTask: AnyCancellable?
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    var currentSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
    var scrollToBottom: (() async -> Void)?
    var decelerating = false
    var lastScrollProxy: ChatCollectionScrollProxy?
    var itemBuilder: ((Item) -> DataView)?
    
    func setupDataSource(collectionView: UICollectionView) {
        let itemRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [weak self] cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                self?.itemBuilder?(item)
            }
            .margins(.all, 0)
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueConfiguredReusableCell(using: itemRegistration, for: indexPath, item: item)
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
            return cell
        }
        
        self.dataSource = dataSource
    }
    
    // MARK: Update
    
    func updateState(collectionView: UICollectionView, items: [Item], section: Section, scrollProxy: ChatCollectionScrollProxy) {
        
        let itemsForSnapshot: [Item] = items.reversed()
        
        guard currentSnapshot.items != itemsForSnapshot else {
            appyScrollProxy(collectionView: collectionView, scrollProxy: scrollProxy, fallbackScrollToTop: false)
            return
        }
        
        var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        snapshot.append(itemsForSnapshot)
        
        // Save the offset by the position of the visible cell
        var oldVisibleCellAttributes: UICollectionViewLayoutAttributes?
        var visibleNewItemIndex: Int?
        
        for visibleItem in currentSnapshot.visibleItems {
            if let newIndex = snapshot.index(of: visibleItem) {
                visibleNewItemIndex = newIndex
                if let oldIndex = currentSnapshot.index(of: visibleItem) {
                    oldVisibleCellAttributes = collectionView.layoutAttributesForItem(at: IndexPath(row: oldIndex, section: 0))
                }
                break
            }
        }
        
        let oldContentSize = collectionView.contentSize
        let oldContentOffset = collectionView.contentOffset
        
        currentSnapshot = snapshot
        
        CATransaction.begin()
        
        dataSource?.apply(snapshot, to: section, animatingDifferences: false) { [weak self] in
            guard let self else { return }
            
            guard !decelerating, // If is not scroll animation
                collectionView.contentSize.height != oldContentSize.height, // If the height has changed
                oldContentSize.height != 0, // If is not first update
                let oldVisibleCellAttributes, // If the old state contains a visible cell that will be used to calculate the difference
                let visibleNewItemIndex,
                  // If the new state contains the same cell
                let visibleCellAttributes = collectionView.layoutAttributesForItem(at: IndexPath(row: visibleNewItemIndex, section: 0))
            else {
                CATransaction.commit()
                return
            }
                
            let diffY = visibleCellAttributes.frame.minY - oldVisibleCellAttributes.frame.minY
            
            let offsetY = oldContentOffset.y + diffY
            if collectionView.contentOffset.y != offsetY {
                collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
            }
            
            // Sometimes the collection may be rendered with an incorrect offset.
            // Apply the update only after set the correct offset
            CATransaction.commit()
            
            appyScrollProxy(collectionView: collectionView, scrollProxy: scrollProxy, fallbackScrollToTop: oldContentOffset.y == 0)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize.isNotZero else { return }
        
        let distance = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.height
        
        if distanceForLoadNextPage > distance {
            if canCallScrollToBottom, scrollUpdateTask.isNil {
                canCallScrollToBottom = false
                scrollUpdateTask = Task { [weak self] in
                    await self?.scrollToBottom?()
                    self?.scrollUpdateTask = nil
                }.cancellable()
            }
        } else {
            canCallScrollToBottom = true
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        decelerating = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        decelerating = false
    }
    
    // MARK: - Private
    
    private func appyScrollProxy(collectionView: UICollectionView, scrollProxy: ChatCollectionScrollProxy, fallbackScrollToTop: Bool) {
        guard lastScrollProxy != scrollProxy else {
            if fallbackScrollToTop {
                scrollToTop(collectionView: collectionView)
            }
            return
        }
        
        switch scrollProxy.scrollOperation {
        case .scrollTo(let itemId, let position):
            if scrollTo(collectionView: collectionView, itemId: itemId, position: position.collectionViewPosition) {
                lastScrollProxy = scrollProxy
            }
        case .none:
            if fallbackScrollToTop {
                scrollToTop(collectionView: collectionView)
            }
            lastScrollProxy = scrollProxy
        }
    }
    
    private func scrollTo(collectionView: UICollectionView, itemId: String, position: UICollectionView.ScrollPosition) -> Bool {
        if let item = currentSnapshot.items.first(where: { $0.id == itemId }),
           let index = currentSnapshot.index(of: item) {
            collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: position, animated: true)
            return true
        }
        return false
    }
    
    private func scrollToTop(collectionView: UICollectionView) {
        collectionView.setContentOffset(CGPoint.zero, animated: true)
    }
}
