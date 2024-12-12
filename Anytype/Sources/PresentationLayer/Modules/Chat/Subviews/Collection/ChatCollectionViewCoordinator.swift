import Foundation
import SwiftUI
import Combine
import UIKit

final class ChatCollectionViewCoordinator<
    Section: Hashable & ChatCollectionSection & Identifiable,
    Item: Hashable & Identifiable,
    DataView: View,
    HeaderView: View>: NSObject, UICollectionViewDelegate where Item.ID == String, Section.Item == Item {
    
    private let distanceForLoadNextPage: CGFloat = 300
    private var canCallScrollToBottom = false
    private var scrollUpdateTask: AnyCancellable?
    private var sections: [Section] = []
    private var dataSourceApplyTransaction = false
    
    var dataSource: UICollectionViewDiffableDataSource<Section.ID, Item>?
    var scrollToBottom: (() async -> Void)?
    var decelerating = false
    var lastScrollProxy: ChatCollectionScrollProxy?
    var itemBuilder: ((Item) -> DataView)?
    var headerBuilder: ((Section.Header) -> HeaderView)?
    
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
        
        let itemRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [weak self] cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                self?.itemBuilder?(item)
            }
            .margins(.all, 0)
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
            canCallScrollToBottom = true
            dataSourceApplyTransaction = false
            CATransaction.commit()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !dataSourceApplyTransaction, scrollView.contentSize.height > 0 else { return }
        
        let distance = scrollView.contentOffset.y - scrollView.topOffset.y
        
        if distanceForLoadNextPage > distance {
            if canCallScrollToBottom, scrollUpdateTask.isNil {
                canCallScrollToBottom = false
                scrollUpdateTask = Task { [weak self] in
                    await self?.scrollToBottom?()
                    self?.scrollUpdateTask = nil
                }.cancellable()
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        decelerating = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        decelerating = false
    }
    
    // MARK: - Private
    
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
}
