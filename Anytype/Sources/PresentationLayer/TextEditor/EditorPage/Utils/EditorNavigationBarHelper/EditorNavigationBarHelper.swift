import Foundation
import UIKit
import BlocksModels

final class EditorNavigationBarHelper {
    
    private weak var controller: UIViewController?
    
    private let fakeNavigationBarBackgroundView = UIView()
    private let navigationBarTitleView = EditorNavigationBarTitleView()
    
    private let settingsItem: EditorBarButtonItem
    private let syncStatusItem = EditorSyncStatusItem(status: .unknown)
    
    private var contentOffsetObservation: NSKeyValueObservation?
    
    private var isObjectHeaderWithCover = false
    
    private var startAppearingOffset: CGFloat = 0.0
    private var endAppearingOffset: CGFloat = 0.0
    var canChangeSyncStatusAppearance = true
        
    init(onSettingsBarButtonItemTap: @escaping () -> Void) {
        self.settingsItem = EditorBarButtonItem(image: .editorNavigation.more, action: onSettingsBarButtonItemTap)
        
        self.fakeNavigationBarBackgroundView.backgroundColor = .backgroundPrimary
        self.fakeNavigationBarBackgroundView.alpha = 0.0
        
        self.navigationBarTitleView.setAlphaForSubviews(0.0)
        
        self.syncStatusItem.isHidden = true
    }
    
}

// MARK: - EditorNavigationBarHelperProtocol

extension EditorNavigationBarHelper: EditorNavigationBarHelperProtocol {
    
    func addFakeNavigationBarBackgroundView(to view: UIView) {
        view.addSubview(fakeNavigationBarBackgroundView) {
            $0.top.equal(to: view.topAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.bottom.equal(to: view.layoutMarginsGuide.topAnchor)
        }
    }
    
    func handleViewWillAppear(_ vc: UIViewController?, _ scrollView: UIScrollView) {
        guard let vc = vc else { return }
        
        configureNavigationItem(in: vc)
        
        contentOffsetObservation = scrollView.observe(
            \.contentOffset,
            options: .new
        ) { [weak self] scrollView, _ in
            self?.updateNavigationBarAppearanceBasedOnContentOffset(scrollView.contentOffset.y + scrollView.contentInset.top)
        }
    }
    
    func handleViewWillDisappear() {
        contentOffsetObservation?.invalidate()
        contentOffsetObservation = nil
    }
    
    func configureNavigationBar(using header: ObjectHeader, details: ObjectDetails?) {
        isObjectHeaderWithCover = header.isWithCover
        startAppearingOffset = header.startAppearingOffset
        endAppearingOffset = header.endAppearingOffset
        
        updateBarButtonItemsBackground(percent: 0)

        navigationBarTitleView.configure(
            model: EditorNavigationBarTitleView.Model(
                icon: details?.objectIconImage,
                title: details?.title
            )
        )
    }
    
    func updateSyncStatus(_ status: SyncStatus) {
        if canChangeSyncStatusAppearance { syncStatusItem.isHidden = false }
        syncStatusItem.changeStatus(status)
    }
    
    func setNavigationBarHidden(_ hidden: Bool) {
        controller?.navigationController?.navigationBar.alpha = hidden ? 0 : 1
        fakeNavigationBarBackgroundView.isHidden = hidden
    }
}

// MARK: - Private extension

private extension EditorNavigationBarHelper {
    
    func configureNavigationItem(in vc: UIViewController) {
        vc.navigationItem.titleView = navigationBarTitleView
        vc.navigationItem.backBarButtonItem = nil
        vc.navigationItem.hidesBackButton = true
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: settingsItem
        )
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: syncStatusItem
        )
        
        controller = vc
        
        setNavigationBarHidden(false)
    }
    
    func updateBarButtonItemsBackground(percent: CGFloat) {
        let state = EditorBarItemState(haveBackground: isObjectHeaderWithCover, percentOfNavigationAppearance: percent)
        settingsItem.changeState(state)
        syncStatusItem.changeState(state)
    }
    
    func updateNavigationBarAppearanceBasedOnContentOffset(_ newOffset: CGFloat) {
        guard let alpha = countPercentOfNavigationBarAppearance(offset: newOffset) else { return }

        navigationBarTitleView.setAlphaForSubviews(alpha)
        updateBarButtonItemsBackground(percent: alpha)
        fakeNavigationBarBackgroundView.alpha = alpha
    }
    
    private func countPercentOfNavigationBarAppearance(offset: CGFloat) -> CGFloat? {
        let navigationBarHeight = fakeNavigationBarBackgroundView.bounds.height
        let yFullOffset = offset + navigationBarHeight

        if yFullOffset < startAppearingOffset {
            return 0
        } else if yFullOffset > endAppearingOffset {
            return 1
        } else if yFullOffset > startAppearingOffset, yFullOffset < endAppearingOffset {
            let currentDiff = yFullOffset - startAppearingOffset
            let max = endAppearingOffset - startAppearingOffset
            return currentDiff / max
        }
        
        return nil
    }
    
}

// MARK: - ObjectHeader

private extension ObjectHeader {
    
    var isWithCover: Bool {
        switch self {
        case .filled(let filledState):
            return filledState.isWithCover
        case .empty:
            return false
        }
    }
    
    var startAppearingOffset: CGFloat {
        switch self {
        case .filled:
            return ObjectHeaderView.Constants.height - 100
            
        case .empty:
            return ObjectHeaderEmptyContentView.Constants.height - 50
        }
    }
    
    var endAppearingOffset: CGFloat {
        switch self {
        case .filled:
            return ObjectHeaderView.Constants.height
            
        case .empty:
            return ObjectHeaderEmptyContentView.Constants.height
        }
    }
    
}
