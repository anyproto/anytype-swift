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
        
        var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        snapshot.append(items.reversed())
//        let needsScrollToBottom = collectionView.contentOffset.y == 0
//        let contentSize = collectionView.contentSize
        context.coordinator.dataSource?.apply(snapshot, to: .one, animatingDifferences: false) {
//            if needsScrollToBottom {
//                collectionView.contentOffset = CGPoint(x: 0, y: 0)
//            }
        }
//        context.coordinator.canCallScrollToBottom = true
        
//        let bottomOffset = collectionView.contentSize.height - collectionView.contentOffset.y
//        context.coordinator.dataSource?.apply(snapshot, to: .one, animatingDifferences: false) {
//            let items = collectionView.numberOfItems(inSection: 0)
//            if items > 0 {
//                collectionView.scrollToItem(at: IndexPath(item: items - 1, section: 0), at: .bottom, animated: false)
//            }
//            let newBottomOffset = collectionView.contentSize.height - collectionView.contentOffset.y - collectionView.bounds.height
//            print("newBottomOffset \(newBottomOffset)")
//            collectionView.setContentOffset(CGPoint(x: 0, y: newBottomOffset - bottomOffset), animated: false)
//        }
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
