import Foundation
import UIKit
import Services

@MainActor
final class EditorNavigationBarHelper {
    
    private let navigationBarView: EditorNavigationBarView
    private let navigationBarBackgroundView: UIView
    
    private let fakeNavigationBarBackgroundView = UIView()
    private let navigationBarTitleView = EditorNavigationBarTitleView()
    
    private let doneButton: UIButton

    private let settingsItem: UIEditorBarButtonItem
    private let syncStatusItem: EditorSyncStatusItem

    private var contentOffsetObservation: NSKeyValueObservation?
    
    private var isObjectHeaderWithCover = false
    
    private var startAppearingOffset: CGFloat = 0.0
    private var endAppearingOffset: CGFloat = 0.0
    private var currentScrollViewOffset: CGFloat = 0.0

    private var currentEditorState: EditorEditingState?
    private var lastMode: EditorNavigationBarTitleView.Mode?
    private var readonlyReason: BlocksReadonlyReason?

    private let onTemplatesButtonTap: () -> Void
        
    init(
        navigationBarView: EditorNavigationBarView,
        navigationBarBackgroundView: UIView,
        syncStatusData: SyncStatusData,
        onSettingsBarButtonItemTap: @escaping () -> Void,
        onDoneBarButtonItemTap: @escaping () -> Void,
        onTemplatesButtonTap: @escaping () -> Void
    ) {
        self.navigationBarView = navigationBarView
        self.navigationBarBackgroundView = navigationBarBackgroundView
        self.settingsItem = UIEditorBarButtonItem(imageAsset: .X24.more, action: onSettingsBarButtonItemTap)
        self.syncStatusItem = EditorSyncStatusItem(statusData: syncStatusData)

        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.title = Loc.done
        buttonConfig.baseForegroundColor = .Button.accent
        self.doneButton = UIButton(configuration: buttonConfig)
        self.doneButton.addAction(
            UIAction(
                handler: { _ in
                    onDoneBarButtonItemTap()
                }
            ),
            for: .touchUpInside
        )
        self.onTemplatesButtonTap = onTemplatesButtonTap


        self.fakeNavigationBarBackgroundView.backgroundColor = .Background.primary
        self.fakeNavigationBarBackgroundView.alpha = 0.0
        self.fakeNavigationBarBackgroundView.layer.zPosition = 1
        
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
            $0.bottom.equal(to: navigationBarView.bottomAnchor)
        }
    }
    
    func handleViewWillAppear(scrollView: UIScrollView) {
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
    
    func configureNavigationBar(using header: ObjectHeader) {
        isObjectHeaderWithCover = header.hasCover
        startAppearingOffset = header.startAppearingOffset
        endAppearingOffset = header.endAppearingOffset
        
        updateBarButtonItemsBackground(opacity: 0)
    }

    func configureNavigationTitle(using details: ObjectDetails?, templatesCount: Int) {
        let mode: EditorNavigationBarTitleView.Mode
        if templatesCount >= Constants.minimumTemplatesAvailableToPick {
            let model = EditorNavigationBarTitleView.Mode.TemplatesModel(
                count: templatesCount + 1,
                onTap: onTemplatesButtonTap
            )
            mode = .templates(model)

        } else {
            let titleModel = EditorNavigationBarTitleView.Mode.TitleModel(
                icon: details?.objectIconImage,
                title: details?.title
            )
            mode = .title(titleModel)
        }
        navigationBarTitleView.configure(model: mode)
        updateNavigationBarAppearanceBasedOnContentOffset(currentScrollViewOffset)
        lastMode = mode
    }
    
    func updatePermissions(_ permissions: ObjectPermissions) {
        switch permissions.editBlocks {
        case .edit:
            readonlyReason = nil
        case .readonly(let reason):
            readonlyReason = reason
        }
    }
    
    func updateSyncStatusData(_ statusData: SyncStatusData) {
        syncStatusItem.changeStatusData(statusData)
    }

    func editorEditingStateDidChange(_ state: EditorEditingState) {
        currentEditorState = state
        switch state {
        case .editing:
            navigationBarView.titleView = navigationBarTitleView
            navigationBarView.rightButton = settingsItem
            navigationBarView.leftButton = syncStatusItem
            lastMode.map { navigationBarTitleView.configure(model: $0) }
            navigationBarTitleView.setIsReadonly(nil)
            updateNavigationBarAppearanceBasedOnContentOffset(currentScrollViewOffset)
        case .selecting(let blocks):
            navigationBarTitleView.setAlphaForSubviews(1)
            updateBarButtonItemsBackground(opacity: 1)
            navigationBarBackgroundView.alpha = 1
            navigationBarView.leftButton = nil
            navigationBarView.rightButton = doneButton
            let title = Loc.selectedBlocks(blocks.count)
            navigationBarTitleView.configure(model: .modeTitle(title))
            navigationBarTitleView.setIsReadonly(nil)
        case .moving:
            let title = Loc.Editor.MovingState.scrollToSelectedPlace
            navigationBarTitleView.configure(model: .modeTitle(title))
            navigationBarView.leftButton = nil
            navigationBarView.rightButton = nil
            navigationBarTitleView.setIsReadonly(nil)
        case .readonly:
            navigationBarView.titleView = navigationBarTitleView
            navigationBarView.rightButton = settingsItem
            navigationBarView.leftButton = syncStatusItem
            lastMode.map { navigationBarTitleView.configure(model: $0) }
            navigationBarTitleView.setIsReadonly(readonlyReason)
            updateNavigationBarAppearanceBasedOnContentOffset(currentScrollViewOffset)
        case let .simpleTablesSelection(_, selectedBlocks, _):
            navigationBarTitleView.setAlphaForSubviews(1)
            updateBarButtonItemsBackground(opacity: 1)
            navigationBarBackgroundView.alpha = 1
            navigationBarView.leftButton = nil
            navigationBarView.rightButton = doneButton
            let title = Loc.selectedBlocks(selectedBlocks.count)
            navigationBarTitleView.configure(model: .modeTitle(title))
            navigationBarTitleView.setIsReadonly(nil)
        case .loading:
            navigationBarView.titleView = navigationBarTitleView
            navigationBarView.rightButton = nil
            navigationBarView.leftButton = syncStatusItem
            navigationBarTitleView.setIsReadonly(nil)
        }
    }
}

// MARK: - Private extension

private extension EditorNavigationBarHelper {
    
    func updateBarButtonItemsBackground(opacity: CGFloat) {
        let state = EditorBarItemState(haveBackground: isObjectHeaderWithCover, opacity: opacity)
        settingsItem.changeState(state)
        syncStatusItem.changeState(state)
    }
    
    func updateNavigationBarAppearanceBasedOnContentOffset(_ newOffset: CGFloat) {
        currentScrollViewOffset = newOffset
        guard let percent = countPercentOfNavigationBarAppearance(offset: newOffset) else { return }

        switch currentEditorState {
            case .editing, .readonly: break
            default: return
        }
        
        // From 0 to 0.5 percent -> opacity 0..1
        let barButtonsOpacity = min(percent, 0.5) * 2
        // From 0.5 to 1 percent -> alpha 0..1
        let titleAlpha = (max(percent, 0.5) - 0.5) * 2
        
        navigationBarTitleView.setAlphaForSubviews(titleAlpha)
        updateBarButtonItemsBackground(opacity: barButtonsOpacity)
//        navigationBarView.setBackgroundAlpha(alpha: percent)
        navigationBarBackgroundView.alpha = percent
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

private extension EditorNavigationBarHelper {
    private enum Constants {
        static let minimumTemplatesAvailableToPick = 1
    }
}

// MARK: - ObjectHeader

private extension ObjectHeader {
    
    var hasCover: Bool {
        switch self {
        case .filled(let filledState, _):
            return filledState.hasCover
        case .empty:
            return false
        }
    }
    
    var startAppearingOffset: CGFloat {
        switch self {
        case .filled:
            return ObjectHeaderConstants.coverHeight - 100
            
        case .empty:
            return ObjectHeaderConstants.emptyViewHeight - 50
        }
    }
    
    var endAppearingOffset: CGFloat {
        switch self {
        case .filled:
            return ObjectHeaderConstants.coverHeight
            
        case .empty:
            return ObjectHeaderConstants.emptyViewHeight
        }
    }
    
}
