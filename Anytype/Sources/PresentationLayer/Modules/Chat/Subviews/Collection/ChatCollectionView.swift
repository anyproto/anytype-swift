import Foundation
import SwiftUI
import Combine
import UIKit

struct ChatCollectionView<
    Item: Hashable & Identifiable,
    Section: Hashable & Identifiable & ChatCollectionSection,
    ItemView: View,
    HeaderView: View,
    BottomPanel: View>: UIViewControllerRepresentable where Item.ID == String, Section.Item == Item {
    
    let items: [Section]
    let scrollProxy: ChatCollectionScrollProxy
    let bottomPanel: BottomPanel
    let itemBuilder: (Item) -> ItemView
    let headerBuilder: (Section.Header) -> HeaderView
    let scrollToBottom: () async -> Void
    
    func makeUIViewController(context: Context) -> ChatCollectionViewContainer<BottomPanel> {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.showsSeparators = false
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.interGroupSpacing = 12
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            section.decorationItems = [] // Delete section background
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .bottom
            )
            
            section.boundarySupplementaryItems = [header]
            
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
        context.coordinator.headerBuilder = headerBuilder
        context.coordinator.scrollToBottom = scrollToBottom
        context.coordinator.updateState(collectionView: container.collectionView, sections: items, scrollProxy: scrollProxy)
    }
    
    func makeCoordinator() -> ChatCollectionViewCoordinator<Section, Item, ItemView, HeaderView> {
        ChatCollectionViewCoordinator<Section, Item, ItemView, HeaderView>()
    }
}
