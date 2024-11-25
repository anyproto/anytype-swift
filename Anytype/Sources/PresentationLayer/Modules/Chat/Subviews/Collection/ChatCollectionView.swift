import Foundation
import SwiftUI
import Combine
import UIKit

struct ChatCollectionView<Item: Hashable & Identifiable, DataView: View, BottomPanel: View>: UIViewControllerRepresentable where Item.ID == String {

    enum OneSection {
        case one
    }
    
    let items: [Item]
    let scrollProxy: ChatCollectionScrollProxy
    let bottomPanel: BottomPanel
    let itemBuilder: (Item) -> DataView
    let scrollToBottom: () async -> Void
    
    func makeUIViewController(context: Context) -> ChatCollectionViewContainer<BottomPanel> {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.headerMode = .none
            configuration.showsSeparators = false
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
            section.decorationItems = [] // Delete section background
            return section
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
        collectionView.delegate = context.coordinator
        collectionView.scrollsToTop = false
        
        if #available(iOS 16.4, *) {
            collectionView.keyboardDismissMode = .interactive
        } else {
            // Safe area regions can be disabled starting from iOS 16.4.
            // Without disabling safe area regions on iOS 16.0, interactive behavior will not work correctly.
            collectionView.keyboardDismissMode = .onDrag
        }
        
        let itemRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
            (cell, indexPath, item) in
            
            cell.contentConfiguration = UIHostingConfiguration {
                itemBuilder(item)
            }
            .margins(.all, 0)
        }
        
        context.coordinator.setupDataSource(collectionView: collectionView)
        
        let bottomPanel = UIHostingController(rootView: bottomPanel)
        bottomPanel.view.backgroundColor = .clear
        bottomPanel.sizingOptions = [.intrinsicContentSize]
        
        if #available(iOS 16.4, *) {
            bottomPanel.safeAreaRegions = SafeAreaRegions()
        }
        
        let container = ChatCollectionViewContainer(collectionView: collectionView, bottomPanel: bottomPanel)
        container.contentInset = UIEdgeInsets(top: HomeTabBarView.height, left: 0, bottom: 10, right: 0)
        return container
    }
    
    func updateUIViewController(_ container: ChatCollectionViewContainer<BottomPanel>, context: Context) {
        container.bottomPanel.rootView = bottomPanel
        context.coordinator.itemBuilder = itemBuilder
        context.coordinator.scrollToBottom = scrollToBottom
        context.coordinator.updateState(collectionView: container.collectionView, items: items, section: .one, scrollProxy: scrollProxy)
    }
    
    func makeCoordinator() -> ChatCollectionViewCoordinator<OneSection, Item, DataView> {
        ChatCollectionViewCoordinator<OneSection, Item, DataView>()
    }
}


