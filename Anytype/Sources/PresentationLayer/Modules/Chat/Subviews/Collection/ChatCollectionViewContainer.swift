import SwiftUI
import UIKit

final class ChatCollectionViewContainer<BottomPanel: View, EmptyView: View, ActionView: View>: UIViewController {
    
    let collectionView: UICollectionView
    let bottomPanel: UIHostingController<BottomPanel>
    let emptyView: UIHostingController<EmptyView>
    let actionView: UIHostingController<ActionView>
    
    private let bottomBlurEffectView = HomeBlurEffectUIView()
    private var bottomTopConstraint: NSLayoutConstraint?
    
    var contentInset: UIEdgeInsets = .zero { didSet { updateInsets(animatedIfNear: false) } }
    
    private var keyboardHeight: CGFloat = 0
    private var bottomPanelHeight: CGFloat = 0
    
    private var keyboardListener: KeyboardEventsListnerHelper?
    private var restoreZeroScrollViewOffset = false
    
    init(
        collectionView: UICollectionView,
        bottomPanel: UIHostingController<BottomPanel>,
        emptyView: UIHostingController<EmptyView>,
        actionView: UIHostingController<ActionView>
    ) {
        self.collectionView = collectionView
        self.bottomPanel = bottomPanel
        self.emptyView = emptyView
        self.actionView = actionView
        super.init(nibName: nil, bundle: nil)
        
        bottomBlurEffectView.direction = .bottomToTop
        
        keyboardListener = KeyboardEventsListnerHelper(
            willShowAction: { [weak self] event in
                guard self?.presentedViewController == nil else { return }
                event.animate { [weak self] in
                    guard let self, let endFrame = event.endFrame else { return }
                    
                    let nearBottom = contentOffsetIsNearBottom()
                    let keyboardFrameInView = view.convert(endFrame, from: nil).intersection(view.bounds)
                    keyboardHeight = keyboardFrameInView.height
                    updateInsets()
                    if nearBottom {
                        setBottomContentOffset()
                    }
                }
            },
            didChangeFrame: { [weak self] event in
                guard self?.presentedViewController == nil else { return }
                event.animate { [weak self] in
                    guard let self, let endFrame = event.endFrame else { return }
                    let keyboardFrameInView = view.convert(endFrame, from: nil).intersection(view.bounds)
                    keyboardHeight = keyboardFrameInView.height
                    updateInsets()
                }
            },
            willHideAction: { [weak self] event in
                guard self?.presentedViewController == nil else { return }
                event.animate { [weak self] in
                    guard let self, let endFrame = event.endFrame else { return }
                    let keyboardFrameInView = view.convert(endFrame, from: nil).intersection(view.bounds)
                    keyboardHeight = keyboardFrameInView.height
                    updateInsets()
                }
            }
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        // The root container includes a bottom panel that changes it's position if the user dismisses the keyboard interactively.
        // This action triggers layoutSubviews for the collection, causing a scrolling glitch.
        // The NSLayoutConstraint for the collection should not be invalidated, making this behavior very unusual.
        // Wrapping the collection in a container resolves this issue.
        let collectionViewContainer = UIView()
        
        addChild(emptyView)
        collectionViewContainer.addSubview(emptyView.view) {
            $0.pinToSuperview()
        }
        emptyView.didMove(toParent: self)
        
        collectionViewContainer.addSubview(collectionView) {
            $0.pinToSuperview()
        }
        view.addSubview(collectionViewContainer) {
            $0.pinToSuperview()
        }
        
        view.addSubview(bottomBlurEffectView) {
            $0.pinToSuperview(excluding: [.top])
        }
        
        addChild(bottomPanel)
        view.addSubview(bottomPanel.view) {
            $0.pinToSuperview(excluding: [.top, .bottom])
            $0.bottom.equal(to: view.keyboardLayoutGuide.topAnchor)
        }
        bottomPanel.didMove(toParent: self)
        
        addChild(actionView)
        view.addSubview(actionView.view) {
            $0.bottom.equal(to: bottomPanel.view.topAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
        }
        actionView.didMove(toParent: self)
        
        bottomTopConstraint = bottomBlurEffectView.topAnchor.constraint(equalTo: bottomPanel.view.topAnchor, constant: 0)
        bottomTopConstraint?.isActive = true
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateInsets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if bottomPanelHeight != bottomPanel.view.frame.height {
            let oldBottomPanelHeight = bottomPanelHeight
            bottomPanelHeight = bottomPanel.view.frame.height
            updateInsets(animatedIfNear: oldBottomPanelHeight != 0)
            updateKeyboardOffset()
        }
    }
    
    private func updateInsets(animatedIfNear: Bool = true) {
        let keyboardHeightWithoutInsets = max((keyboardHeight - view.safeAreaInsets.bottom), 0)
        let newBottomInset = keyboardHeightWithoutInsets + bottomPanelHeight + contentInset.bottom
        
        let newInsets = UIEdgeInsets(
            top: contentInset.top,
            left: contentInset.left,
            bottom: newBottomInset,
            right: contentInset.right
        )
        
        let nearBottom = contentOffsetIsNearBottom()
        
        if nearBottom && animatedIfNear {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.collectionView.contentInset = newInsets
                self?.collectionView.scrollIndicatorInsets = newInsets
                self?.setBottomContentOffset()
            }
        } else {
            collectionView.contentInset = newInsets
            collectionView.scrollIndicatorInsets = newInsets
            if nearBottom {
                setBottomContentOffset()
            }
        }
        
        bottomTopConstraint?.constant = -contentInset.bottom
    }
    
    private func updateKeyboardOffset() {
        if #available(iOS 17.0, *) {
            view.keyboardLayoutGuide.keyboardDismissPadding = bottomPanel.view.frame.height
        }
    }
    
    private func contentOffsetIsNearBottom() -> Bool {
        return collectionView.bottomOffset.y - collectionView.contentOffset.y < 40
    }
    
    private func setBottomContentOffset() {
        collectionView.contentOffset = collectionView.bottomOffset
    }
}
