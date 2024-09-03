import Foundation
import SwiftUI
import Combine

struct DiscussionCollectionView<Item: Hashable, DataView: View>: UIViewRepresentable {

    enum OneSection {
        case one
    }
    
    let items: [Item]
    let itemBuilder: (Item) -> DataView
    let scrollToBottom: () async -> Void
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.headerMode = .none
            configuration.showsSeparators = false
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.interGroupSpacing = 12
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
        
        guard context.coordinator.currentSnapshot?.items != itemsForSnapshot else { return }
        
        var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        snapshot.append(itemsForSnapshot)
        
        let needsScrollToBottom = collectionView.contentOffset.y == 0
        let oldContentSize = collectionView.contentSize
        
        context.coordinator.currentSnapshot = snapshot
        
        CATransaction.begin()
        
        context.coordinator.dataSource?.apply(snapshot, to: .one, animatingDifferences: false) {
            if needsScrollToBottom, collectionView.contentSize.height != oldContentSize.height, oldContentSize.height != 0 {
                let offsetY = collectionView.contentSize.height - oldContentSize.height
                collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
                
                // Sometimes the collection may be rendered with an incorrect offset.
                // Apply the update only after set the correct offset
                CATransaction.commit()
                
                collectionView.setContentOffset(CGPoint.zero, animated: true)
            } else {
                CATransaction.commit()
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
    var currentSnapshot: NSDiffableDataSourceSectionSnapshot<Item>?
    var scrollToBottom: (() async -> Void)?
    
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
}
