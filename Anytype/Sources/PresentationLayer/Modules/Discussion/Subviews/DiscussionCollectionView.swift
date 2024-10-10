import Foundation
import SwiftUI
import Combine

enum DiscussionCollectionDiffApply {
    case scrollToLast
    case auto
}

struct DiscussionCollectionView<Item: Hashable, DataView: View>: UIViewRepresentable {

    enum OneSection {
        case one
    }
    
    let items: [Item]
    let diffApply: DiscussionCollectionDiffApply
    let itemBuilder: (Item) -> DataView
    let scrollToBottom: () async -> Void
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.headerMode = .none
            configuration.showsSeparators = false
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
            return section
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
        collectionView.delegate = context.coordinator
        collectionView.scrollsToTop = false
        
        let itemRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
            (cell, indexPath, item) in
            
            cell.contentConfiguration = UIHostingConfiguration {
                itemBuilder(item)
            }
            .margins(.all, 0)
        }
        
        let dataSource = UICollectionViewDiffableDataSource<OneSection, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
            let cell = collectionView.dequeueConfiguredReusableCell(using: itemRegistration, for: indexPath, item: item)
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
        
        context.coordinator.dataSource = dataSource
        
        return collectionView
    }
    
    func updateUIView(_ collectionView: UICollectionView, context: Context) {
        context.coordinator.scrollToBottom = scrollToBottom
        
        let itemsForSnapshot: [Item] = items.reversed()
        
        guard context.coordinator.currentSnapshot.items != itemsForSnapshot else { return }
        
        var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        snapshot.append(itemsForSnapshot)
        
        // Save the offset by the position of the visible cell
        var oldVisibleCellAttributes: UICollectionViewLayoutAttributes?
        var visibleNewItemIndex: Int?
        
        for visibleItem in context.coordinator.currentSnapshot.visibleItems {
            if let newIndex = snapshot.index(of: visibleItem) {
                visibleNewItemIndex = newIndex
                if let oldIndex = context.coordinator.currentSnapshot.index(of: visibleItem) {
                    oldVisibleCellAttributes = collectionView.layoutAttributesForItem(at: IndexPath(row: oldIndex, section: 0))
                }
                break
            }
        }
        
        let oldContentSize = collectionView.contentSize
        let oldContentOffset = collectionView.contentOffset
        
        context.coordinator.currentSnapshot = snapshot
        
        CATransaction.begin()
        
        context.coordinator.dataSource?.apply(snapshot, to: .one, animatingDifferences: false) {
            guard !context.coordinator.decelerating, // If is not scroll animation
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
            
            if oldContentOffset.y == 0 || diffApply == .scrollToLast {
                collectionView.setContentOffset(CGPoint.zero, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> DiscussionCollectionViewCoordinator<OneSection, Item> {
        DiscussionCollectionViewCoordinator<OneSection, Item>()
    }
}

final class DiscussionCollectionViewCoordinator<Section: Hashable, Item: Hashable>: NSObject, UICollectionViewDelegate {
    
    private let distanceForLoadNextPage: CGFloat = 50
    private var canCallScrollToBottom = false
    private var scrollUpdateTask: AnyCancellable?
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    var currentSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
    var scrollToBottom: (() async -> Void)?
    var decelerating = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let distance = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.height
        if distanceForLoadNextPage > distance {
            if canCallScrollToBottom, scrollUpdateTask.isNil {
                scrollUpdateTask = Task { [weak self] in
                    await self?.scrollToBottom?()
                    self?.canCallScrollToBottom = false
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
}
