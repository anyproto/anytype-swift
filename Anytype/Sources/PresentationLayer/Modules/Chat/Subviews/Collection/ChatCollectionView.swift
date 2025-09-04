import Foundation
import SwiftUI
import Combine
import UIKit

struct ChatCollectionView<
    ItemView: View,
    HeaderView: View,
    BottomPanel: View,
    ActionView: View,
    EmptyView: View>: UIViewControllerRepresentable {
    
    typealias Section = MessageSectionData
    typealias Item = MessageSectionItem
    
    let items: [Section]
    let scrollProxy: ChatCollectionScrollProxy
    let bottomPanel: BottomPanel
    let emptyView: EmptyView
    let showEmptyState: Bool
    @Binding
    var interactionProvider: (any ChatCollectionInteractionProviderProtocol)?
    // Dynamic update doesn't support
    let output: (any MessageModuleOutput)?
    let unreadBuilder: (String) -> ItemView
    let headerBuilder: (Section.Header) -> HeaderView
    @ViewBuilder
    let actionView: ActionView
    let scrollToTop: () async -> Void
    let scrollToBottom: () async -> Void
    let handleVisibleRange: (_ from: Item, _ to: Item) -> Void
    let handleBigDistanceToTheBottom: ((_ isBigDistance: Bool) -> Void)?
    let onTapCollectionBackground: () -> Void
    
    func makeUIViewController(context: Context) -> ChatCollectionViewContainer<BottomPanel, EmptyView, ActionView> {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.delegate = context.coordinator
        collectionView.scrollsToTop = false
        collectionView.showsVerticalScrollIndicator = false
        
        if #available(iOS 16.4, *) {
            collectionView.keyboardDismissMode = .interactive
        } else {
            // Safe area regions can be disabled starting from iOS 16.4.
            // Without disabling safe area regions on iOS 16.0, interactive behavior will not work correctly.
            collectionView.keyboardDismissMode = .onDrag
        }
        
        context.coordinator.setupDataSource(collectionView: collectionView)
        context.coordinator.setupDismissKeyboardOnTap(collectionView: collectionView)
        
        let bottomPanel = UIHostingController(rootView: bottomPanel)
        bottomPanel.view.backgroundColor = .clear
        bottomPanel.sizingOptions = [.intrinsicContentSize]
        
        if #available(iOS 16.4, *) {
            bottomPanel.safeAreaRegions = SafeAreaRegions()
        }
        
        let emptyView = UIHostingController(rootView: emptyView)
        emptyView.view.backgroundColor = .clear
        emptyView.sizingOptions = [.intrinsicContentSize]

        let actionView = UIHostingController(rootView: actionView)
        actionView.view.backgroundColor = .clear
        actionView.sizingOptions = [.intrinsicContentSize]
        
        if #available(iOS 16.4, *) {
            actionView.safeAreaRegions = SafeAreaRegions()
        }
        
        let container = ChatCollectionViewContainer(collectionView: collectionView, bottomPanel: bottomPanel, emptyView: emptyView, actionView: actionView)
        container.contentInset = UIEdgeInsets(top: PageNavigationHeaderConstants.height, left: 0, bottom: 10, right: 0)
        return container
    }
    
    func updateUIViewController(_ container: ChatCollectionViewContainer<BottomPanel, EmptyView, ActionView>, context: Context) {
        container.bottomPanel.rootView = bottomPanel
        container.emptyView.rootView = emptyView
        container.emptyView.view.isHidden = !showEmptyState
        container.actionView.rootView = actionView
        context.coordinator.unreadBuilder = unreadBuilder
        context.coordinator.headerBuilder = headerBuilder
        context.coordinator.scrollToTop = scrollToTop
        context.coordinator.scrollToBottom = scrollToBottom
        context.coordinator.handleVisibleRange = handleVisibleRange
        context.coordinator.handleBigDistanceToTheBottom = handleBigDistanceToTheBottom
        context.coordinator.onTapCollectionBackground = onTapCollectionBackground
        context.coordinator.updateState(collectionView: container.collectionView, sections: items, scrollProxy: scrollProxy)
    }
    
    func makeCoordinator() -> ChatCollectionViewCoordinator<ItemView, HeaderView> {
        let coordinator = ChatCollectionViewCoordinator<ItemView, HeaderView>(output: output)
        DispatchQueue.main.async {
            interactionProvider = coordinator.interactionProvider
        }
        return coordinator
    }
}
