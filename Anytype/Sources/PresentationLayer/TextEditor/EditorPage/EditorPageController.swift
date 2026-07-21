import Services
import UIKit
import Combine
import AnytypeCore
import SwiftUI

enum EditorPageConfigurationConstants {
    static let dataSourceAnimationEnabled = true
}

final class EditorPageController: UIViewController {
    
    let bottomNavigationManager: any EditorBottomNavigationManagerProtocol
    private(set) lazy var dataSource = makeCollectionViewDataSource()
    private(set) weak var firstResponderView: UIView?
    private let layout = EditorCollectionFlowLayout()
    @Injected(\.keyboardHeightListener)
    private var keyboardListener: KeyboardHeightListener
    private lazy var responderScrollViewHelper = ResponderScrollViewHelper(scrollView: collectionView)

    lazy var collectionView: EditorCollectionView = {
        let collectionView = EditorCollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear

        return collectionView
    }()
    
    private(set) var insetsHelper: EditorContentInsetsHelper?
    lazy var dividerCursorController = DividerCursorController(
        movingManager: viewModel.blocksStateManager,
        view: view,
        collectionView: collectionView
    )

    // Gesture recognizer to handle taps in empty document
    private let listViewTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()
    private var shakeGestureStartDate: Date?

    private lazy var longTapGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(EditorPageController.handleLongPress))

        recognizer.minimumPressDuration = 0.3
        return recognizer
    }()

    // Watches a native selection-grabber drag leave the focused text block and escalates it
    // into block multi-select. Recognizes alongside the system text-selection gestures without
    // consuming their touches; see EditorPageController+SelectionEscalation.
    lazy var selectionEscalationPan: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(EditorPageController.handleSelectionEscalationPan))
        recognizer.cancelsTouchesInView = false
        recognizer.delaysTouchesBegan = false
        recognizer.delegate = self
        return recognizer
    }()
    var selectionEscalationAnchor: IndexPath?
    var selectionEscalationPanContext: SelectionEscalationPanContext?
    var selectionEscalationHandoffDeadline: CFTimeInterval = 0
    var selectionEscalationAutoscroll: CADisplayLink?
    var selectionEscalationLastTouchInView: CGPoint?

    private lazy var navigationBarHelper: EditorNavigationBarHelper = EditorNavigationBarHelper(
        navigationBarView: navigationBarView,
        objectId: viewModel.document.objectId,
        spaceId: viewModel.document.spaceId,
        output: viewModel.router,
        onSelectAllBarButtonItemTap: { [weak self] allSelected in
            self?.handleSelectState(allSelected: allSelected)
        },
        onDoneBarButtonItemTap:  { [weak viewModel] in
            viewModel?.blocksStateManager.didSelectEditingMode()
        },
        onTemplatesButtonTap: { [weak viewModel] in
            viewModel?.showTemplates()
        },
        onTitleTap: { [weak viewModel] in
            viewModel?.showWidgets()
        },
        onSyncStatusTap: { [weak viewModel] in
            UISelectionFeedbackGenerator().selectionChanged()
            viewModel?.showSyncStatusInfo()
        }, onWebBannerTap: { [weak viewModel] in
            UISelectionFeedbackGenerator().selectionChanged()
            viewModel?.onPublishingBannerTap()
        }
    )

    private let blocksSelectionOverlayView: BlocksSelectionOverlayView
    private let navigationBarView = EditorNavigationBarView()
    private let navigationBarBlurView = HomeBlurEffectUIView()
    private let showHeader: Bool
    var viewModel: (any EditorPageViewModelProtocol)! {
        didSet {
            // Layout metadata must subscribe before model snapshot updates to avoid first-frame indentation fallback.
            layout.blockLayoutDetailsPublisher = viewModel.document.blockLayoutDetailsPublisher.receiveOnMain().eraseToAnyPublisher()
            viewModel.setupSubscriptions()
        }
    }
    
    private var cancellables = [AnyCancellable]()
    private var applyAnimationConfig = false
    private var dataSourceAnimationEnabled: Bool {
        applyAnimationConfig ? EditorPageConfigurationConstants.dataSourceAnimationEnabled : false
    }
    
    // MARK: - Initializers
    init(
        blocksSelectionOverlayView: BlocksSelectionOverlayView,
        bottomNavigationManager: some EditorBottomNavigationManagerProtocol,
        showHeader: Bool
    ) {
        self.blocksSelectionOverlayView = blocksSelectionOverlayView
        self.bottomNavigationManager = bottomNavigationManager
        self.showHeader = showHeader
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrided functions
    
    override func loadView() {
        super.loadView()
        
        setupView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.dataSource = dataSource
        viewModel.viewDidLoad()
        bindViewModel()
        setEditing(true, animated: false)
        collectionView.allowsSelectionDuringEditing = true

        navigationBarHelper.handleViewWillAppear(scrollView: collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()

        insetsHelper = EditorContentInsetsHelper(
            scrollView: collectionView,
            stateManager: viewModel.blocksStateManager
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.hideKeyboard()
        firstResponderView?.resignFirstResponder()
        view.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDissapear()

        navigationBarHelper.handleViewWillDisappear()
        insetsHelper = nil
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        // collectionView.isEditing can be mutated outside this method;
        // guard on both flags so any drift gets resynced.
        guard isEditing != editing || collectionView.isEditing != editing else { return }
        super.setEditing(editing, animated: animated)
        collectionView.isEditing = editing
        bottomNavigationManager.multiselectActive(!editing)
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)

        if motion == .motionShake && UIAccessibility.isShakeToUndoEnabled {
            shakeGestureStartDate = Date()
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake && UIAccessibility.isShakeToUndoEnabled {
            if let startDate = shakeGestureStartDate {
                defer { shakeGestureStartDate = nil }
                let timeInterval = Date().timeIntervalSince(startDate)
                if timeInterval.rounded() >= Constants.shakeUndoTriggerDuration {
                    viewModel.shakeMotionDidAppear()
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // On iPadOS, when the app window changes between fullscreen, split view, or slide over,
        // we need to redraw the collection view so its cells fit the new size.
        coordinator.animate { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    private func handleState(state: EditorEditingState) {
        navigationBarHelper.editorEditingStateDidChange(state)

        switch state {
        case .selecting:
            view.endEditing(true)
            setEditing(false, animated: true)
            blocksSelectionOverlayView.isHidden = false
            collectionView.isLocked = false
            view.isUserInteractionEnabled = true
            // With no text view active, the controller must sit at the head of the responder
            // chain for the shift+arrow key commands that grow the block selection.
            becomeFirstResponder()
        case .editing:
            selectionEscalationAnchor = nil
            collectionView.deselectAllMovingItems()
            dividerCursorController.movingMode = .none
            setEditing(true, animated: true)
            blocksSelectionOverlayView.isHidden = true
            collectionView.isLocked = false
            view.isUserInteractionEnabled = true
        case .moving(let indexPaths):
            dividerCursorController.movingMode = .drum
            setEditing(false, animated: true)
            indexPaths.forEach { indexPath in
                collectionView.deselectItem(at: indexPath, animated: false)
                collectionView.setItemIsMoving(true, at: indexPath)
            }
            collectionView.isLocked = false
            view.isUserInteractionEnabled = true
        case .readonly:
            view.endEditing(true)
            collectionView.isLocked = true
            view.isUserInteractionEnabled = true
        case .simpleTablesSelection:
            bottomNavigationManager.multiselectActive(true)
            view.endEditing(true)
            collectionView.isLocked = true
        case .loading:
            view.endEditing(true)
            view.isUserInteractionEnabled = false
        }
    }

    func bindViewModel() {
        viewModel.blocksStateManager.editorEditingStatePublisher.receiveOnMain().sink { [weak self] state in
            self?.handleState(state: state)
        }.store(in: &cancellables)

        viewModel.blocksStateManager.editorSelectedBlocks.receiveOnMain().sink { [weak self] blockIds in
            guard let self else { return }
            blockIds.forEach(selectBlock)
        }.store(in: &cancellables)
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        view.endEditing(true)

        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    private func handleSelectState(allSelected: Bool) {
        if allSelected {
            let filtredIndexPaths = collectionView.allIndexPaths.filter { [weak self] indexPath in
                return self?.canSelect(indexPath: indexPath) ?? false
            }
            filtredIndexPaths.forEach { [weak self] indexPath in
                self?.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            }
            viewModel?.blocksStateManager.didUpdateSelectedIndexPaths(filtredIndexPaths, allSelected: allSelected)
        } else {
            collectionView.deselectAllSelectedItems()
            viewModel?.blocksStateManager.didUpdateSelectedIndexPaths([], allSelected: allSelected)
        }
    }
    
    func setPageNavigationHiddenBackButton(_ hidden: Bool) {
        navigationBarHelper.setPageNavigationHiddenBackButton(hidden)
    }
}

// MARK: - EditorPageViewInput

extension EditorPageController: EditorPageViewInput {
    
    func textBlockWillBeginEditing() { }
    
    func visibleRect(to view: UIView) -> CGRect {
        return collectionView.convert(collectionView.bounds, to: view)
    }
    
    func update(header: ObjectHeader) {
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<EditorItem>()
        headerSnapshot.append([.header(header)])
        dataSource.apply(headerSnapshot, to: .header, animatingDifferences: false)
        
        navigationBarHelper.configureNavigationBar(using: header)
    }
    
    func update(details: ObjectDetails?, templatesCount: Int) {
        navigationBarHelper.configureNavigationTitle(using: details,templatesCount: templatesCount)
    }
    
    func update(permissions: ObjectPermissions) {
        navigationBarHelper.updatePermissions(permissions)
    }
    
    func update(syncStatusData: SyncStatusData) {
        navigationBarHelper.updateSyncStatusData(syncStatusData)
    }
    
    func update(webBannerVisible: Bool) {
        navigationBarHelper.updateWebBannerVisibility(webBannerVisible)
    }
    
    func reconfigure(items: [EditorItem]) {
        guard items.count > 0 else { return }

        var snapshot = dataSource.snapshot()
        let notExistingItems = items.filter { !snapshot.itemIdentifiers.contains($0) }
        
        // If we received an update for item not presented in a data source
        // probably the new item is a new view model for an existing block. So we have to check by ID.
        // Example: BlockFileViewModel -> BlockImageViewModel when uploading image into file block
        for item in notExistingItems {
            guard let oldItem = snapshot.itemIdentifiers.first(where: { $0.blockId == item.blockId }) else {
                continue
            }
            guard let index = snapshot.indexOfItem(oldItem) else { continue }
            guard let previousItem = snapshot.itemIdentifiers[safe: index - 1] else {
                anytypeAssertionFailure(
                    "Not found previous item in snapshot",
                    info: ["oldItem": String(describing: oldItem)]
                )
                continue
            }
            
            snapshot.deleteItems([oldItem])
            snapshot.insertItems([item], afterItem: previousItem)
        }
        
        let existingItems = items.filter { snapshot.itemIdentifiers.contains($0) }
        snapshot.reconfigureItems(existingItems)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func update(
        changes: CollectionDifference<EditorItem>?,
        allModels: [EditorItem],
        isRealData: Bool,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        var blocksSnapshot = NSDiffableDataSourceSectionSnapshot<EditorItem>()
        blocksSnapshot.append(allModels)

        applyBlocksSectionSnapshot(
            blocksSnapshot,
            animatingDifferences: animated && dataSourceAnimationEnabled,
            completion: completion
        )
        applyAnimationConfig = isRealData
    }
    
    func scrollToItem(_ item: EditorItem) {
        guard let indexPath = dataSource.indexPath(for: item) else { return }
        collectionView.scrollToItem(at: indexPath, at: [.centeredVertically], animated: false)
    }

    func scrollToTopBlock(blockId: String) {
        guard let item = dataSourceItem(for: blockId),
              let indexPath = dataSource.indexPath(for: item),
              let cellRect = collectionView.layoutAttributesForItem(at: indexPath)?.frame else { return }
        let yOffset = cellRect.minY - view.safeAreaInsets.top
        collectionView.setContentOffset(.init(x: 0, y: yOffset), animated: true)
    }
    
    func scrollToTextViewIfNotVisible(textView: UITextView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak responderScrollViewHelper] in
            responderScrollViewHelper?.scrollBlockToVisibleArea(textView: textView)
        }
    }
    
    func selectBlock(blockId: String) {
        if let item = dataSourceItem(for: blockId),
            let indexPath = dataSource.indexPath(for: item) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])

            let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems ?? []
            viewModel.blocksStateManager.didUpdateSelectedIndexPathsResetIfNeeded(indexPathsForSelectedItems, allSelected: isAllSelected())
        }
    }
    
    func textBlockDidBeginEditing(firstResponderView: UIView) {
        self.firstResponderView = firstResponderView
        // A selection display deactivated during a past Enter handoff (takeFocus) must come
        // back the moment this block is edited again, in case UIKit does not re-activate it
        // on its own — otherwise the block would edit with an invisible caret.
        if let textView = firstResponderView as? UITextView {
            setSelectionDisplay(true, for: textView)
        }
        if let textView = firstResponderView as? TextViewWithPlaceholder {
            textView.onSelectionHandlePan = { [weak self] recognizer in
                self?.handleSelectionEscalationPan(recognizer)
            }
        }
    }

    func itemDidChangeFrame(item: EditorItem) {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let indexPath = dataSource.indexPath(for: item) else { return }
            collectionView.collectionViewLayout.invalidateLayout(
                with: CustomInvalidation(indexPaths: [indexPath])
            )
        }
    }

    func blockDidFinishEditing() {
        self.firstResponderView = nil
    }

    @discardableResult
    func takeFocus(blockId: String, position: BlockFocusPosition) -> Bool {
        guard let item = dataSourceItem(for: blockId),
              let indexPath = dataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath),
              let contentView = firstTextBlockContentView(in: cell) else { return false }
        // Switch the outgoing selection UI off at the interaction level before the responder
        // moves: the caret is a self-perpetuating interaction-owned animation that ignores
        // transaction suppression, but a deactivated interaction has nothing left to fade.
        // This is the documented whole-interaction switch — not the cursorView subview, whose
        // direct mutation leaves ghost carets. Reactivation happens on the next begin-editing
        // of that block (see textBlockDidBeginEditing).
        if let oldTextView = firstResponderView as? UITextView {
            setSelectionDisplay(false, for: oldTextView)
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        UIView.performWithoutAnimation {
            contentView.takeFocus(at: position)
        }
        CATransaction.commit()
        return true
    }

    func isFirstResponderNearBottom() -> Bool {
        guard let firstResponderView else { return false }
        let frame = firstResponderView.convert(firstResponderView.bounds, to: collectionView)
        let visibleMaxY = collectionView.contentOffset.y + collectionView.bounds.height - collectionView.adjustedContentInset.bottom
        // Room below the focused block for one more row of roughly its own height?
        return frame.maxY + frame.height > visibleMaxY
    }

    private func setSelectionDisplay(_ activated: Bool, for textView: UITextView) {
        guard #available(iOS 17.0, *) else { return }
        for interaction in textView.interactions {
            guard let selectionDisplay = interaction as? UITextSelectionDisplayInteraction,
                  selectionDisplay.isActivated != activated else { continue }
            selectionDisplay.isActivated = activated
            selectionDisplay.setNeedsSelectionUpdate()
        }
    }

    func revealBlock(blockId: String) {
        guard let item = dataSourceItem(for: blockId),
              let indexPath = dataSource.indexPath(for: item) else { return }
        // Runs in the same runloop iteration as the updates it follows, so the scroll lands in
        // the same render commit: UIKit's own first-responder reveal comes a tick later, which
        // renders the row change and the scroll as two visible steps.
        UIView.performWithoutAnimation {
            collectionView.layoutIfNeeded()
            guard let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)?.frame else { return }
            let insets = collectionView.adjustedContentInset
            let visibleMinY = collectionView.contentOffset.y + insets.top
            let visibleMaxY = collectionView.contentOffset.y + collectionView.bounds.height - insets.bottom
            var offsetY = collectionView.contentOffset.y
            if cellFrame.maxY > visibleMaxY {
                offsetY += cellFrame.maxY - visibleMaxY
            } else if cellFrame.minY < visibleMinY {
                offsetY -= visibleMinY - cellFrame.minY
            }
            // setContentOffset does not clamp: revealing a row near the document end would
            // otherwise park the view overscrolled past the bottom inset.
            let minOffsetY = -insets.top
            let maxOffsetY = max(minOffsetY, collectionView.contentSize.height - collectionView.bounds.height + insets.bottom)
            offsetY = min(max(offsetY, minOffsetY), maxOffsetY)
            if offsetY != collectionView.contentOffset.y {
                collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: offsetY), animated: false)
            }
        }
    }

    private func firstTextBlockContentView(in view: UIView) -> TextBlockContentView? {
        if let view = view as? TextBlockContentView { return view }
        for subview in view.subviews {
            if let found = firstTextBlockContentView(in: subview) { return found }
        }
        return nil
    }

    // MARK: -
    func endEditing() {
        view.endEditing(true)
        collectionView.isEditing = false
    }

    func adjustContentOffset(relatively: UIView) {
        collectionView.adjustContentOffsetForSelectedItem(relatively: relatively)
    }

    func restoreEditingState() {
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            self?.insetsHelper?.restoreEditingOffset()
        }

        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return }

        collectionView.deselectAllSelectedItems()

        guard let item = dataSource.itemIdentifier(for: selectedIndexPath) else { return }

        switch item {
        case let .block(block):
            viewModel.cursorFocus(blockId: block.blockId)
        case .header, .system:
            return
        }
    }
    
    func isAllSelected() -> Bool {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return false }
        let filtredIndexPaths = collectionView.allIndexPaths.filter { [weak self] indexPath in
            return self?.canSelect(indexPath: indexPath) ?? false
        }
        return selectedItems.count == filtredIndexPaths.count
    }
}

// MARK: - Private extension

private extension EditorPageController {
    
    func setupView() {
        view.backgroundColor = .Background.primary
        setupCollectionView()
        setupInteractions()
        setupLayout()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dropDelegate = self
        collectionView.addGestureRecognizer(self.listViewTapGestureRecognizer)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
    }
    
    func setupInteractions() {
        listViewTapGestureRecognizer.addTarget(
            self,
            action: #selector(tapOnListViewGestureRecognizerHandler)
        )
        collectionView.addGestureRecognizer(listViewTapGestureRecognizer)

        collectionView.addGestureRecognizer(longTapGestureRecognizer)
        collectionView.addGestureRecognizer(selectionEscalationPan)
    }
    
    func setupLayout() {
        view.addSubview(collectionView) {
            $0.pinToSuperview()
        }

        view.addSubview(blocksSelectionOverlayView) {
            $0.pinToSuperview()
        }
        if showHeader {
            navigationBarBlurView.direction = .topToBottom
            view.addSubview(navigationBarBlurView) {
                $0.pinToSuperview(excluding: [.bottom])
            }
            view.addSubview(navigationBarView) {
                $0.pinToSuperview(excluding: [.bottom, .top])
                $0.top.equal(to: view.safeAreaLayoutGuide.topAnchor)
                $0.bottom.equal(to: navigationBarBlurView.bottomAnchor)
            }
        }
        blocksSelectionOverlayView.isHidden = true
    }

    func reloadCell(for item: EditorItem) {
        guard let indexPath = dataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }
        let newConfiguration: any UIContentConfiguration
        
        switch item {
        case .header: return
        case .block(let blockViewModel):
            newConfiguration = blockViewModel.makeContentConfiguration(maxWidth: cell.bounds.width)
        case .system(let systemContentConfiguationProvider):
            newConfiguration = systemContentConfiguationProvider.makeContentConfiguration(maxWidth: cell.bounds.width)
        }
        
        cell.contentConfiguration = newConfiguration
    }

    func dataSourceItem(for blockId: String) -> EditorItem? {
        dataSource.snapshot().itemIdentifiers.first {
            switch $0 {
            case let .block(block):
                return block.info.id == blockId
            case .header, .system:
                return false
            }
        }
    }
    
    @objc
    func tapOnListViewGestureRecognizerHandler() {
        guard collectionView.isEditing && !collectionView.isLocked && dividerCursorController.movingMode != .drum else { return }
        let location = self.listViewTapGestureRecognizer.location(in: collectionView)
        let cellIndexPath = collectionView.indexPathForItem(at: location)
        guard cellIndexPath == nil else { return }

        viewModel.tapOnEmptyPlace(isBelowContent: location.y >= contentMaxY)
    }

    // Bottom edge of the last laid-out item. Taps below it target the trailing area;
    // taps in gaps between blocks must not create anything.
    private var contentMaxY: CGFloat {
        var maxY: CGFloat = 0
        for section in 0..<collectionView.numberOfSections {
            let itemsCount = collectionView.numberOfItems(inSection: section)
            guard itemsCount > 0 else { continue }
            let indexPath = IndexPath(item: itemsCount - 1, section: section)
            guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else { continue }
            maxY = max(maxY, attributes.frame.maxY)
        }
        return maxY
    }

    @objc
    private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard dividerCursorController.movingMode != .drum else { return }

        guard gesture.state == .ended, !collectionView.isLocked else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let location = gesture.location(in: collectionView)
        collectionView.indexPathForItem(at: location).map {
            viewModel.blocksStateManager.didLongTap(at: $0)
        }
    }
    
    func makeCollectionViewDataSource() -> UICollectionViewDiffableDataSource<EditorSection, EditorItem> {
        let headerCellRegistration = createHeaderCellRegistration()
        let cellRegistration = createCellRegistration()
        let systemCellRegistration = createSystemCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<EditorSection, EditorItem>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, dataSourceItem) -> UICollectionViewCell? in
            let cell: UICollectionViewCell
            switch dataSourceItem {
            case let .block(block):
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: block
                )
            case let .header(header):
                return collectionView.dequeueConfiguredReusableCell(
                    using: headerCellRegistration,
                    for: indexPath,
                    item: header
                )
            case let .system(configuration):
                return collectionView.dequeueConfiguredReusableCell(
                    using: systemCellRegistration,
                    for: indexPath,
                    item: configuration
                )
            }

            // UIKit bug. isSelected works fine, UIConfigurationStateCustomKey properties sometimes switch to adjacent cellsAnytype/Sources/PresentationLayer/TextEditor/BlocksViews/Base/CustomStateKeys.swift
            if let self = self {
                (cell as? EditorViewListCell)?.isMoving = self.collectionView.indexPathsForMovingItems.contains(indexPath)
                (cell as? EditorViewListCell)?.isLocked = self.collectionView.isLocked
            }
            return cell
        }

        var initialSnapshot = NSDiffableDataSourceSnapshot<EditorSection, EditorItem>()
        initialSnapshot.appendSections(EditorSection.allCases)
        
        dataSource.apply(initialSnapshot, animatingDifferences: false)
        
        return dataSource
    }
    
    func createHeaderCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, ObjectHeader> {
        .init { cell, _, item in
            cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }
    }
    
    func createCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, any BlockViewModelProtocol> {
        .init { [weak self] cell, indexPath, item in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }
    }
    
    func createSystemCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, any SystemContentConfiguationProvider> {
        .init { (cell, indexPath, item) in
            cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        }
    }
    
    func setupCell(cell: UICollectionViewListCell, indexPath: IndexPath, item: some BlockViewModelProtocol) {
        cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        cell.contentView.isUserInteractionEnabled = true
        
        cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        if FeatureFlags.rainbowViews {
            cell.fillSubviewsWithRandomColors(recursively: false)
        }
    }
    
}

// MARK: - Initial Update data

private extension EditorPageController {
    func applyBlocksSectionSnapshot(
        _ snapshot: NSDiffableDataSourceSectionSnapshot<EditorItem>,
        animatingDifferences: Bool,
        completion: @escaping () -> Void
    ) {
        dataSource.apply(
            snapshot,
            to: .main,
            animatingDifferences: animatingDifferences,
            completion: completion
        )

        let selectedCells = collectionView.indexPathsForSelectedItems
        selectedCells?.forEach {
            collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
        }
    }
}

private enum Constants {
    static let shakeUndoTriggerDuration: CGFloat = 1
}

