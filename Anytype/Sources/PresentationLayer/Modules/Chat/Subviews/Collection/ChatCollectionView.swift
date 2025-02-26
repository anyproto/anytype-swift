import Foundation
import SwiftUI
import Combine
import UIKit

struct ChatCollectionView<
    Item: Hashable & Identifiable,
    Section: Hashable & Identifiable & ChatCollectionSection,
    ItemView: View,
    HeaderView: View,
    BottomPanel: View,
    EmptyView: View>: UIViewControllerRepresentable where Item.ID == String, Section.Item == Item {
    
    let items: [Section]
    let scrollProxy: ChatCollectionScrollProxy
    let bottomPanel: BottomPanel
    let emptyView: EmptyView
    let showEmptyState: Bool
    let itemBuilder: (Item) -> ItemView
    let headerBuilder: (Section.Header) -> HeaderView
    let scrollToTop: () async -> Void
    let scrollToBottom: () async -> Void
    let handleVisibleRange: (_ fromId: String, _ toId: String) -> Void
    
    func makeUIViewController(context: Context) -> ChatCollectionViewContainer<BottomPanel, EmptyView> {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
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
            
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
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
        
        let emptyView = UIHostingController(rootView: emptyView)
        emptyView.view.backgroundColor = .clear
        emptyView.sizingOptions = [.intrinsicContentSize]
        
        if #available(iOS 16.4, *) {
            bottomPanel.safeAreaRegions = SafeAreaRegions()
        }
        
        let container = ChatCollectionViewContainer(collectionView: collectionView, bottomPanel: bottomPanel, emptyView: emptyView)
        container.contentInset = UIEdgeInsets(top: PageNavigationHeaderConstants.height, left: 0, bottom: 10, right: 0)
        return container
    }
    
    func updateUIViewController(_ container: ChatCollectionViewContainer<BottomPanel, EmptyView>, context: Context) {
        container.bottomPanel.rootView = bottomPanel
        container.emptyView.view.isHidden = !showEmptyState
        context.coordinator.itemBuilder = itemBuilder
        context.coordinator.headerBuilder = headerBuilder
        context.coordinator.scrollToTop = scrollToTop
        context.coordinator.scrollToBottom = scrollToBottom
        context.coordinator.handleVisibleRange = handleVisibleRange
        context.coordinator.updateState(collectionView: container.collectionView, sections: items, scrollProxy: scrollProxy)
    }
    
    func makeCoordinator() -> ChatCollectionViewCoordinator<Section, Item, ItemView, HeaderView> {
        ChatCollectionViewCoordinator<Section, Item, ItemView, HeaderView>()
    }
}
