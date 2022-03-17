import Foundation
import UIKit
import BlocksModels

final class EditorNavigationBarHelper {
    
    private weak var controller: UIViewController?
    
    private let fakeNavigationBarBackgroundView = UIView()
    private let navigationBarTitleView = EditorNavigationBarTitleView()
    
    private lazy var settingsBarButtonItem = UIBarButtonItem(customView: settingsItem)
    private let doneBarButtonItem: UIBarButtonItem
    private lazy var syncStatusBarButtonItem = UIBarButtonItem(customView: syncStatusItem)

    private let settingsItem: UIEditorBarButtonItem
    private let syncStatusItem = EditorSyncStatusItem(status: .unknown)

    private var contentOffsetObservation: NSKeyValueObservation?
    
    private var isObjectHeaderWithCover = false
    
    private var startAppearingOffset: CGFloat = 0.0
    private var endAppearingOffset: CGFloat = 0.0
    var canChangeSyncStatusAppearance = true

    private var currentEditorState: EditorEditingState?
    private var lastTitleModel: EditorNavigationBarTitleView.Mode.TitleModel?
        
    init(
        viewController: UIViewController,
        onSettingsBarButtonItemTap: @escaping () -> Void,
        onDoneBarButtonItemTap: @escaping () -> Void
    ) {
        self.controller = viewController
        self.settingsItem = UIEditorBarButtonItem(image: .more, action: onSettingsBarButtonItemTap)

        self.doneBarButtonItem = UIBarButtonItem(
            title: "Done".localized,
            image: nil,
            primaryAction: UIAction(handler: { _ in onDoneBarButtonItemTap() }),
            menu: nil
        )
        self.doneBarButtonItem.tintColor = UIColor.buttonAccent


        self.fakeNavigationBarBackgroundView.backgroundColor = .backgroundPrimary
        self.fakeNavigationBarBackgroundView.alpha = 0.0
        
        self.navigationBarTitleView.setAlphaForSubviews(0.0)
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
    
    func handleViewWillAppear(scrollView: UIScrollView) {
        configureNavigationItem()
        
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
        isObjectHeaderWithCover = header.hasCover
        startAppearingOffset = header.startAppearingOffset
        endAppearingOffset = header.endAppearingOffset
        
        updateBarButtonItemsBackground(opacity: 0)

        let titleModel = EditorNavigationBarTitleView.Mode.TitleModel(
            icon: details?.objectIconImage,
            title: details?.title
        )
        self.lastTitleModel = titleModel

        navigationBarTitleView.configure(
            model: .title(titleModel)
        )
    }
    
    func updateSyncStatus(_ status: SyncStatus) {
        syncStatusItem.changeStatus(status)
    }

    func editorEditingStateDidChange(_ state: EditorEditingState) {
        currentEditorState = state
        switch state {
        case .editing:
            controller?.navigationItem.titleView = navigationBarTitleView
            controller?.navigationItem.rightBarButtonItem = settingsBarButtonItem
            controller?.navigationItem.leftBarButtonItem = syncStatusBarButtonItem
            lastTitleModel.map { navigationBarTitleView.configure(model: .title($0)) }
        case .selecting(let blocks):
            navigationBarTitleView.setAlphaForSubviews(1)
            updateBarButtonItemsBackground(opacity: 1)
            fakeNavigationBarBackgroundView.alpha = 1
            controller?.navigationItem.leftBarButtonItem = nil
            controller?.navigationItem.rightBarButtonItem = doneBarButtonItem
            let title: String
            switch blocks.count {
            case 1:
                title = "\(blocks.count) " + "selected block".localized
            default:
                title = "\(blocks.count) " + "selected blocks".localized
            }
            navigationBarTitleView.configure(model: .modeTitle(title))
        case .moving:
            let title = "Editor.MovingState.ScrollToSelectedPlace".localized
            navigationBarTitleView.configure(model: .modeTitle(title))
            controller?.navigationItem.rightBarButtonItem = doneBarButtonItem
        }
    }
}

// MARK: - Private extension

private extension EditorNavigationBarHelper {
    
    func configureNavigationItem() {
        controller?.navigationItem.backBarButtonItem = nil
        controller?.navigationItem.hidesBackButton = true
    }
    
    func updateBarButtonItemsBackground(opacity: CGFloat) {
        let state = EditorBarItemState(haveBackground: isObjectHeaderWithCover, opacity: opacity)
        settingsItem.changeState(state)
        syncStatusItem.changeState(state)
    }
    
    func updateNavigationBarAppearanceBasedOnContentOffset(_ newOffset: CGFloat) {
        guard let opacity = countPercentOfNavigationBarAppearance(offset: newOffset) else { return }
        guard case .editing = currentEditorState else { return }

        navigationBarTitleView.setAlphaForSubviews(opacity)
        updateBarButtonItemsBackground(opacity: opacity)
        fakeNavigationBarBackgroundView.alpha = opacity
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
    
    var hasCover: Bool {
        switch self {
        case .filled(let filledState):
            return filledState.hasCover
        case .empty:
            return false
        }
    }
    
    var startAppearingOffset: CGFloat {
        switch self {
        case .filled:
            return ObjectHeaderConstants.height - 100
            
        case .empty:
            return ObjectHeaderConstants.emptyViewHeight - 50
        }
    }
    
    var endAppearingOffset: CGFloat {
        switch self {
        case .filled:
            return ObjectHeaderConstants.height
            
        case .empty:
            return ObjectHeaderConstants.emptyViewHeight
        }
    }
    
}
