import Foundation
import SwiftUI
import Combine
import UIKit

struct ChatCollectionView<
    Item: Hashable & Identifiable & Sendable,
    Section: Hashable & Identifiable & ChatCollectionSection & Sendable,
    ItemView: View,
    HeaderView: View,
    BottomPanel: View,
    ActionView: View,
    EmptyView: View>: UIViewControllerRepresentable where Item.ID == String, Section.Item == Item, Section.ID: Sendable {
    
    let items: [Section]
    let scrollProxy: ChatCollectionScrollProxy
    let bottomPanel: BottomPanel
    let emptyView: EmptyView
    let showEmptyState: Bool
    let itemBuilder: (Item) -> ItemView
    let headerBuilder: (Section.Header) -> HeaderView
    @ViewBuilder
    let actionView: ActionView
    let scrollToTop: () async -> Void
    let scrollToBottom: () async -> Void
    let handleVisibleRange: (_ from: Item, _ to: Item) -> Void
    let handleBigDistanceToTheBottom: ((_ isBigDistance: Bool) -> Void)?
    let onTapCollectionBackground: () -> Void
    
    func makeUIViewController(context: Context) -> ChatCollectionViewContainer<BottomPanel, EmptyView, ActionView> {
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
            header.pinToVisibleBounds = true
            
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.delegate = context.coordinator
        collectionView.scrollsToTop = false
        collectionView.showsVerticalScrollIndicator = false

        collectionView.keyboardDismissMode = .interactive

        context.coordinator.setupDataSource(collectionView: collectionView)
        context.coordinator.setupDismissKeyboardOnTap(collectionView: collectionView)
        
        let bottomPanel = UIHostingController(rootView: bottomPanel)
        bottomPanel.view.backgroundColor = .clear
        bottomPanel.sizingOptions = [.intrinsicContentSize]

        bottomPanel.safeAreaRegions = SafeAreaRegions()

        let emptyView = UIHostingController(rootView: emptyView)
        emptyView.view.backgroundColor = .clear
        emptyView.sizingOptions = [.intrinsicContentSize]

        let actionView = UIHostingController(rootView: actionView)
        actionView.view.backgroundColor = .clear
        actionView.sizingOptions = [.intrinsicContentSize]

        actionView.safeAreaRegions = SafeAreaRegions()

        let container = ChatCollectionViewContainer(collectionView: collectionView, bottomPanel: bottomPanel, emptyView: emptyView, actionView: actionView)
        container.contentInset = UIEdgeInsets(top: PageNavigationHeaderConstants.height, left: 0, bottom: 10, right: 0)
        return container
    }
    
    func updateUIViewController(_ container: ChatCollectionViewContainer<BottomPanel, EmptyView, ActionView>, context: Context) {
        container.bottomPanel.rootView = bottomPanel
        container.emptyView.rootView = emptyView
        container.emptyView.view.isHidden = !showEmptyState
        container.actionView.rootView = actionView
        context.coordinator.itemBuilder = itemBuilder
        context.coordinator.headerBuilder = headerBuilder
        context.coordinator.scrollToTop = scrollToTop
        context.coordinator.scrollToBottom = scrollToBottom
        context.coordinator.handleVisibleRange = handleVisibleRange
        context.coordinator.handleBigDistanceToTheBottom = handleBigDistanceToTheBottom
        context.coordinator.onTapCollectionBackground = onTapCollectionBackground
        context.coordinator.updateState(collectionView: container.collectionView, sections: items, scrollProxy: scrollProxy)
    }
    
    func makeCoordinator() -> ChatCollectionViewCoordinator<Section, Item, ItemView, HeaderView> {
        ChatCollectionViewCoordinator<Section, Item, ItemView, HeaderView>()
    }
}
