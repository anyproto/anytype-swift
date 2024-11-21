import SwiftUI
import UIKit

final class CollectionViewContainer<BottomPanel: View>: UIViewController {
    
    let collectionView: UICollectionView
    let bottomPanel: UIHostingController<BottomPanel>
    
    private let topBlurEffectView = HomeBlurEffectUIView()
    private let bottomBlurEffectView = HomeBlurEffectUIView()
    private var topHeightConstraint: NSLayoutConstraint?
    private var bottomTopConstraint: NSLayoutConstraint?
    
    var contentInset: UIEdgeInsets = .zero { didSet { updateInsets() } }
    
    private var keyboardHeight: CGFloat = 0 { didSet { updateInsets() } }
    private var bottomPanelHeight: CGFloat = 0 {
        didSet {
            updateInsets()
            updateKeyboardOffset()
        }
    }
    
    private var keyboardListener: KeyboardEventsListnerHelper?
    private var restoreZeroScrollViewOffset = false
    
    init(collectionView: UICollectionView, bottomPanel: UIHostingController<BottomPanel>) {
        self.collectionView = collectionView
        self.bottomPanel = bottomPanel
        super.init(nibName: nil, bundle: nil)
        
        bottomBlurEffectView.direction = .bottomToTop
        
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
            didChangeFrame: { [weak self] event in
                event.animate { [weak self] in
                    guard let self, let endFrame = event.endFrame else { return }
                    let keyboardFrameInView = view.convert(endFrame, from: nil).intersection(view.bounds)
                    keyboardHeight = keyboardFrameInView.height
                }
            },
            willHideAction: { [weak self] event in
                // Ignore handling when user show context menu
                guard self?.presentedViewController == nil else { return }
                event.animate { [weak self] in
                    guard let self, let endFrame = event.endFrame else { return }
                    let keyboardFrameInView = view.convert(endFrame, from: nil).intersection(view.bounds)
                    keyboardHeight = keyboardFrameInView.height
                }
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
        }
        bottomPanel.didMove(toParent: self)
        
        topHeightConstraint = topBlurEffectView.heightAnchor.constraint(equalToConstant: 0)
        topHeightConstraint?.isActive = true
        
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
            bottomPanelHeight = bottomPanel.view.frame.height
        }
    }
    
    private func updateInsets() {
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
    }
    
    private func updateKeyboardOffset() {
        if #available(iOS 17.0, *) {
            view.keyboardLayoutGuide.keyboardDismissPadding = bottomPanel.view.frame.height
        }
    }
    
    private func contentOffsetIsNearZero() -> Bool {
        return collectionView.adjustedContentInset.top + collectionView.contentOffset.y < 40
    }
    
    private func setZeroContentOffset() {
        collectionView.contentOffset = CGPoint(x: 0, y: -collectionView.adjustedContentInset.top)
    }
}
