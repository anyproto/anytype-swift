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
//    let bottomInteractiveInsetChanged: (CGFloat) -> Void
    
    func makeUIViewController(context: Context) -> CollectionViewContainer<BottomPanel> {
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
//        collectionView.transform = CGAffineTransform(rotationAngle: .pi)
        collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
        collectionView.delegate = context.coordinator
        collectionView.scrollsToTop = false
//        collectionView.insetsLayoutMarginsFromSafeArea = false
//        collectionView.contentInsetAdjustmentBehavior = .never
        
        if #available(iOS 16.4, *) {
            collectionView.keyboardDismissMode = .interactive
        } else {
            collectionView.keyboardDismissMode = .onDrag
        }
//        collectionView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 70, right: 0)
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 64, left: 0, bottom: 70, right: 0)
        
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
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
            return cell
        }
        
        context.coordinator.dataSource = dataSource
        
        let bottomPanel = UIHostingController(rootView: bottomPanel)
        bottomPanel.view.backgroundColor = .clear
        bottomPanel.sizingOptions = [.intrinsicContentSize]
        
        if #available(iOS 16.4, *) {
            bottomPanel.safeAreaRegions = SafeAreaRegions()
        }
        
        let container = CollectionViewContainer(collectionView: collectionView, bottomPanel: bottomPanel)
        container.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 10, right: 0)
        return container
    }
    
    func updateUIViewController(_ container: CollectionViewContainer<BottomPanel>, context: Context) {
        
        container.bottomPanel.rootView = bottomPanel
//        container.bottomInteractiveInsetChanged = bottomInteractiveInsetChanged
        
        context.coordinator.scrollToBottom = scrollToBottom
        context.coordinator.updateState(collectionView: container.collectionView, items: items, section: .one, scrollProxy: scrollProxy)
    }
    
    func makeCoordinator() -> ChatCollectionViewCoordinator<OneSection, Item> {
        ChatCollectionViewCoordinator<OneSection, Item>()
    }
}

final class CollectionViewContainer<BottomPanel: View>: UIViewController {
    
    let collectionView: UICollectionView
    let bottomPanel: UIHostingController<BottomPanel>
    
    private let topBlurEffectView = HomeBlurEffectUIView()
    private let bottomBlurEffectView = HomeBlurEffectUIView()
    private var topHeightConstraint: NSLayoutConstraint?
    private var bottomTopConstraint: NSLayoutConstraint?
    
//    var bottomInteractiveInsetChanged: ((CGFloat) -> Void)?
    
    var contentInset: UIEdgeInsets = .zero { didSet { updateInsets() } }
    
    private var keyboardHeight: CGFloat = 0 { didSet { updateInsets() } }
    private var bottomPanelHeight: CGFloat = 0 {
        didSet {
            updateInsets()
            updateKeyboardOffset()
        }
    }
//    private var observation: NSKeyValueObservation?
    
    private var keyboardListener: KeyboardEventsListnerHelper?
    private var restoreZeroScrollViewOffset = false
    
    init(collectionView: UICollectionView, bottomPanel: UIHostingController<BottomPanel>) {
        self.collectionView = collectionView
        self.bottomPanel = bottomPanel
        super.init(nibName: nil, bundle: nil)
        
        bottomBlurEffectView.direction = .bottomToTop
//        bottomBlurEffectView.backgroundColor = .orange
        
        keyboardListener = KeyboardEventsListnerHelper(
            willShowAction: { [weak self] event in
                event.animate { [weak self] in
                    guard let self, let endFrame = event.endFrame else { return }

                    let nearZero = contentOffsetIsNearZero()
                    
                    let keyboardFrameInView = view.convert(endFrame, from: nil).intersection(view.bounds)
                    keyboardHeight = keyboardFrameInView.height
                    if nearZero {
                        setZeroContentOffset()
                    }
                }
               
                
            },
            willHideAction: { [weak self] event in
                event.animate { [weak self] in
                    guard let self, let endFrame = event.endFrame else { return }
                    let keyboardFrameInView = view.convert(endFrame, from: nil).intersection(view.bounds)
                    keyboardHeight = keyboardFrameInView.height
                }
//                self?.keyboardHeight = event.endFrame?.height ?? 0
//                print("willHideAction")
//                self?.checkIfOffsetShouldBeRestored()
            },
            didHideAction: { [weak self] event in
//                print("didHideAction")
//                self?.restoreOffsetIfNeeded()
//                guard let self, let endFrame = event.beginFrame else { return }
//                keyboardHeight = view.convert(endFrame, from: nil).height
//                print("keyboardHeight did hide \(keyboardHeight)")
            }
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(collectionView) {
            $0.pinToSuperview()
        }
        
        view.addSubview(topBlurEffectView) {
            $0.pinToSuperview(excluding: [.bottom])
        }
        
        view.addSubview(bottomBlurEffectView) {
            $0.pinToSuperview(excluding: [.top])
        }
        
        addChild(bottomPanel)
        view.addSubview(bottomPanel.view) {
            $0.pinToSuperview(excluding: [.top, .bottom])
            $0.bottom.equal(to: view.keyboardLayoutGuide.topAnchor)
//            $0.height.equal(to: 100)
        }
        bottomPanel.didMove(toParent: self)
        
        topHeightConstraint = topBlurEffectView.heightAnchor.constraint(equalToConstant: 0)
        topHeightConstraint?.isActive = true
        
        bottomTopConstraint = bottomBlurEffectView.topAnchor.constraint(equalTo: bottomPanel.view.topAnchor, constant: 0)
        bottomTopConstraint?.isActive = true
        
        
//        observation = bottomPanel.view.observe(\.frame) { object, change in
//            print("new value \(change.newValue)")
//        }
        
//        bottomPanel.view.addObserver(self, forKeyPath: "frame", context: T##UnsafeMutableRawPointer?)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateInsets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if bottomPanelHeight != bottomPanel.view.frame.height {
            bottomPanelHeight = bottomPanel.view.frame.height
        }
//        keyboardHeight = bottomPanel.view.keyboardLayoutGuide.layoutFrame.height
    }
    
    private func updateInsets() {
//        var bottomInset = contentInset.bottom + bottomPanel.view.frame.height
//        var newInset = contentInset
        let keyboardHeightWithoutInsets = max((keyboardHeight - view.safeAreaInsets.bottom), 0)
        let newBottomInset = keyboardHeightWithoutInsets + bottomPanelHeight + contentInset.bottom
        // Safe area rotated
        let safeAreaDiff = collectionView.safeAreaInsets.top - collectionView.safeAreaInsets.bottom
        
        let newInsets = UIEdgeInsets(
            top: newBottomInset - safeAreaDiff,
            left: contentInset.left,
            bottom: contentInset.top + safeAreaDiff,
            right: contentInset.right
        )
        
        let nearZero = contentOffsetIsNearZero()
        
        
        if nearZero {
            UIView.animate(withDuration: 0.3) { [weak self] in
                
                self?.collectionView.contentInset = newInsets
                self?.collectionView.scrollIndicatorInsets = newInsets
                self?.setZeroContentOffset()
            }
        } else {
            
            collectionView.contentInset = newInsets
            collectionView.scrollIndicatorInsets = newInsets
        }
        
        topHeightConstraint?.constant = contentInset.top + view.safeAreaInsets.top
        bottomTopConstraint?.constant = -contentInset.bottom
//        bottomHeightConstraint?.constant = newBottomInset + view.safeAreaInsets.bottom
        
//        bottomInteractiveInsetChanged?(keyboardHeightWithoutInsets + bottomPanelHeight)
    }
    
    private func updateKeyboardOffset() {
        if #available(iOS 17.0, *) {
            view.keyboardLayoutGuide.keyboardDismissPadding = bottomPanel.view.frame.height
        }
    }
    
    private func contentOffsetIsNearZero() -> Bool {
        return collectionView.adjustedContentInset.top + collectionView.contentOffset.y < 20
    }
    
    private func setZeroContentOffset() {
        collectionView.contentOffset = CGPoint(x: 0, y: -collectionView.adjustedContentInset.top)
    }
    
//    private func checkIfOffsetShouldBeRestored() {
//        restoreZeroScrollViewOffset = collectionView.contentOffset.y < 5
//    }
//    
//    private func restoreOffsetIfNeeded() {
//        if restoreZeroScrollViewOffset {
//            collectionView.contentOffset = CGPoint(x: 0, y: -collectionView.adjustedContentInset.top)
////            collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentInset.top), animated: true)
//            restoreZeroScrollViewOffset = false
//        }
//    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
        
//        bottomPanel.view.sizeToFit()
//    }
    
//    private func collectionOffsetIsNearZero() -> Bool {
//        if
//    }
}

final class ChatCollectionViewCoordinator<Section: Hashable, Item: Hashable & Identifiable>: NSObject, UICollectionViewDelegate where Item.ID == String {
    
    private let distanceForLoadNextPage: CGFloat = 50
    private var canCallScrollToBottom = false
    private var scrollUpdateTask: AnyCancellable?
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    var currentSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
    var scrollToBottom: (() async -> Void)?
    var decelerating = false
    var lastScrollProxy: ChatCollectionScrollProxy?
    
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
        let distance = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.height + scrollView.adjustedContentInset.bottom
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


//extension UIHostingController {
//
//    convenience public init(rootView: Content, ignoreSafeArea: Bool) {
//        self.init(rootView: rootView)
//
//        if ignoreSafeArea {
//            disableSafeArea()
//        }
//    }
//
//    func disableSafeArea() {
//        guard let viewClass = object_getClass(view) else {
//            return
//        }
//
//        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
//
//        if let viewSubclass = NSClassFromString(viewSubclassName) {
//            object_setClass(view, viewSubclass)
//        } else {
//            guard
//                let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String,
//                let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0)
//            else {
//                return
//            }
//
//            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
//                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
//                    return .zero
//                }
//
//                class_addMethod(
//                    viewSubclass,
//                    #selector(getter: UIView.safeAreaInsets),
//                    imp_implementationWithBlock(safeAreaInsets),
//                    method_getTypeEncoding(method)
//                )
//            }
//
//            objc_registerClassPair(viewSubclass)
//            object_setClass(view, viewSubclass)
//        }
//    }
//}
