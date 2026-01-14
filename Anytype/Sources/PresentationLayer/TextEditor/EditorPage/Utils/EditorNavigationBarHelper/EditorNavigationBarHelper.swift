import Foundation
import UIKit
import Services
import SwiftUI

@MainActor
final class EditorNavigationBarHelper {
    
    private let navigationBarView: EditorNavigationBarView
    private let navigationBarBackgroundView: UIView
    
    private let fakeNavigationBarBackgroundView = UIView()
    private let navigationBarTitleView = EditorNavigationBarTitleView()
    
    private let doneButton: UIButton
    private let selectAllButton: UIButton

    private let settingsMenuView: UIView
    private let syncStatusItem: EditorSyncStatusItem
    private let syncStatusGlassContainer: GlassEffectViewIOS26
    private let settingsGlassContainer: GlassEffectViewIOS26
    private let webBannerItem: EditorWebBannerItem
    private let rightContanerForEditing: UIView
    private let backButton: UIView
    private let backButtonGlassContainer: GlassEffectViewIOS26
    
    private var contentOffsetObservation: NSKeyValueObservation?
    
    private var isObjectHeaderWithCover = false
    
    private var startAppearingOffset: CGFloat = 0.0
    private var endAppearingOffset: CGFloat = 0.0
    private var currentScrollViewOffset: CGFloat = 0.0

    private var currentEditorState: EditorEditingState?
    private var lastMode: EditorNavigationBarTitleView.Mode?
    private var readonlyReason: BlocksReadonlyReason?

    private let onTemplatesButtonTap: () -> Void
    private let onTitleTap: () -> Void

    init(
        navigationBarView: EditorNavigationBarView,
        navigationBarBackgroundView: UIView,
        objectId: String,
        spaceId: String,
        output: (any ObjectSettingsCoordinatorOutput)?,
        onSelectAllBarButtonItemTap: @escaping (Bool) -> Void,
        onDoneBarButtonItemTap: @escaping () -> Void,
        onTemplatesButtonTap: @escaping () -> Void,
        onTitleTap: @escaping () -> Void,
        onSyncStatusTap: @escaping () -> Void,
        onWebBannerTap: @escaping () -> Void
    ) {
        self.navigationBarView = navigationBarView
        self.navigationBarBackgroundView = navigationBarBackgroundView

        let menuContainer = ObjectSettingsMenuContainer(objectId: objectId, spaceId: spaceId, output: output)
        let hostingController = UIHostingController(rootView: menuContainer)
        hostingController.view.backgroundColor = .clear
        self.settingsMenuView = hostingController.view

        let syncStatusItemLocal = EditorSyncStatusItem(onTap: onSyncStatusTap)
        let syncStatusGlassContainerLocal = GlassEffectViewIOS26()
        let settingsGlassContainerLocal = GlassEffectViewIOS26()

        self.syncStatusItem = syncStatusItemLocal
        self.syncStatusGlassContainer = syncStatusGlassContainerLocal
        self.settingsGlassContainer = settingsGlassContainerLocal
        self.webBannerItem = EditorWebBannerItem(onTap: onWebBannerTap)

        // Setup glass containers for buttons
        syncStatusGlassContainerLocal.applyCircleShape(diameter: 44)
        syncStatusGlassContainerLocal.layoutUsing.anchors {
            $0.size(CGSize(width: 44, height: 44))
        }
        syncStatusGlassContainerLocal.glassContentView.addSubview(syncStatusItemLocal) {
            $0.center(in: syncStatusGlassContainerLocal.glassContentView)
        }

        settingsGlassContainerLocal.applyCircleShape(diameter: 44)
        settingsGlassContainerLocal.layoutUsing.anchors {
            $0.size(CGSize(width: 44, height: 44))
        }

        // Done button
        var doneButtonConfig = UIButton.Configuration.glassIOS26()
        doneButtonConfig.title = Loc.done
        doneButtonConfig.baseForegroundColor = .Control.accent100
        self.doneButton = UIButton(configuration: doneButtonConfig)
        self.doneButton.addAction(
            UIAction(
                handler: { _ in
                    onDoneBarButtonItemTap()
                }
            ),
            for: .touchUpInside
        )
        
        self.onTemplatesButtonTap = onTemplatesButtonTap
        self.onTitleTap = onTitleTap

        self.fakeNavigationBarBackgroundView.backgroundColor = .Background.primary
        self.fakeNavigationBarBackgroundView.alpha = 0.0
        self.fakeNavigationBarBackgroundView.layer.zPosition = 1
        
        self.navigationBarTitleView.setAlphaForSubviews(1.0)
        
        self.rightContanerForEditing = UIView()

        let backButtonLocal = UIHostingController(rootView: PageNavigationBackButton()).view!
        backButtonLocal.backgroundColor = .clear
        let backButtonGlassContainerLocal = GlassEffectViewIOS26()

        self.backButton = backButtonLocal
        self.backButtonGlassContainer = backButtonGlassContainerLocal

        // Setup back button glass container
        backButtonGlassContainerLocal.applyCircleShape(diameter: 44)
        backButtonGlassContainerLocal.layoutUsing.anchors {
            $0.size(CGSize(width: 44, height: 44))
        }
        backButtonGlassContainerLocal.glassContentView.addSubview(backButtonLocal) {
            $0.center(in: backButtonGlassContainerLocal.glassContentView)
        }
        
        // Select all button
        var selectAllConfig = UIButton.Configuration.glassIOS26()
        selectAllConfig.baseForegroundColor = .Control.secondary
        self.selectAllButton = UIButton(configuration: selectAllConfig)
        self.selectAllButton.addAction(
            UIAction(
                handler: { [weak self] _ in
                    guard let allSelected = self?.currentEditorState?.allSelected else { return }
                    onSelectAllBarButtonItemTap(!allSelected)
                }
            ),
            for: .touchUpInside
        )
        
        // Add settings menu to glass container
        settingsGlassContainerLocal.glassContentView.addSubview(settingsMenuView) {
            $0.center(in: settingsGlassContainerLocal.glassContentView)
        }

        self.rightContanerForEditing.layoutUsing.stack {
            $0.hStack(
                spacing: 8,
                syncStatusGlassContainerLocal,
                settingsGlassContainerLocal
            )
        }
        
        navigationBarView.bannerView = webBannerItem
    }
    
    func setPageNavigationHiddenBackButton(_ hidden: Bool) {
        backButtonGlassContainer.isHidden = hidden
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
            MainActor.assumeIsolated {
                self?.updateNavigationBarAppearanceBasedOnContentOffset(scrollView.contentOffset.y + scrollView.contentInset.top)
            }
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
                count: templatesCount,
                onTap: onTemplatesButtonTap
            )
            mode = .templates(model)

        } else {
            let titleModel = EditorNavigationBarTitleView.Mode.TitleModel(
                icon: details?.objectIconImage,
                title: details?.title,
                onTap: onTitleTap
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
    
    func updateWebBannerVisibility(_ isVisible: Bool) {
        webBannerItem.setVisible(isVisible)
    }

    func editorEditingStateDidChange(_ state: EditorEditingState) {
        currentEditorState = state
        switch state {
        case .editing:
            navigationBarView.titleView = navigationBarTitleView
            navigationBarView.rightButton = rightContanerForEditing
            navigationBarView.leftButton = backButtonGlassContainer
            lastMode.map { navigationBarTitleView.configure(model: $0) }
            navigationBarTitleView.setIsReadonly(nil)
            updateNavigationBarAppearanceBasedOnContentOffset(currentScrollViewOffset)
            settingsGlassContainer.isHidden = false
        case .selecting(let blocks, let allSelected):
            navigationBarTitleView.setAlphaForSubviews(1)
            updateBarButtonItemsBackground(opacity: 1)
            navigationBarBackgroundView.alpha = 1
            selectAllButton.setTitle(allSelected ? Loc.deselect : Loc.selectAll, for: .normal)
            navigationBarView.leftButton = selectAllButton
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
            navigationBarView.rightButton = rightContanerForEditing
            navigationBarView.leftButton = backButtonGlassContainer
            lastMode.map { navigationBarTitleView.configure(model: $0) }
            navigationBarTitleView.setIsReadonly(readonlyReason)
            updateNavigationBarAppearanceBasedOnContentOffset(currentScrollViewOffset)
            settingsGlassContainer.isHidden = false
        case let .simpleTablesSelection(_, selectedBlocks, _):
            navigationBarTitleView.setAlphaForSubviews(1)
            updateBarButtonItemsBackground(opacity: 1)
            navigationBarBackgroundView.alpha = 1
            navigationBarView.leftButton = selectAllButton
            navigationBarView.rightButton = doneButton
            let title = Loc.selectedBlocks(selectedBlocks.count)
            navigationBarTitleView.configure(model: .modeTitle(title))
            navigationBarTitleView.setIsReadonly(nil)
        case .loading:
            navigationBarView.titleView = navigationBarTitleView
            navigationBarView.rightButton = rightContanerForEditing
            navigationBarView.leftButton = backButtonGlassContainer
            navigationBarTitleView.setIsReadonly(nil)
            settingsGlassContainer.isHidden = true
        }
    }
}

// MARK: - Private extension

private extension EditorNavigationBarHelper {
    
    func updateBarButtonItemsBackground(opacity: CGFloat) {
        // Glass containers handle their own appearance - no opacity updates needed
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
        // Title always visible
        let titleAlpha: CGFloat = 1.0

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
        static let minimumTemplatesAvailableToPick = 2
    }
}

// MARK: - ObjectHeader

private extension ObjectHeader {
    
    var hasCover: Bool {
        switch self {
        case .filled(let filledState, _, _):
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
