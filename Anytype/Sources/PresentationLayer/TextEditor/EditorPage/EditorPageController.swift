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
    private weak var firstResponderView: UIView?
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

    private lazy var navigationBarHelper: EditorNavigationBarHelper = EditorNavigationBarHelper(
        navigationBarView: navigationBarView,
        navigationBarBackgroundView: navigationBarBackgroundView, 
        onSettingsBarButtonItemTap: { [weak viewModel] in
            UISelectionFeedbackGenerator().selectionChanged()
            viewModel?.showSettings()
        }, 
        onSelectAllBarButtonItemTap: { [weak self] allSelected in
            self?.handleSelectState(allSelected: allSelected)
        },
        onDoneBarButtonItemTap:  { [weak viewModel] in
            viewModel?.blocksStateManager.didSelectEditingMode()
        },
        onTemplatesButtonTap: { [weak viewModel] in
            viewModel?.showTemplates()
        }, 
        onSyncStatusTap: { [weak viewModel] in
            UISelectionFeedbackGenerator().selectionChanged()
            viewModel?.showSyncStatusInfo()
        }
    )

    private let blocksSelectionOverlayView: BlocksSelectionOverlayView
    private let navigationBarView = EditorNavigationBarView()
    private let navigationBarBackgroundView = UIView()
    private let showHeader: Bool
    var viewModel: (any EditorPageViewModelProtocol)! {
        didSet {
            viewModel.setupSubscriptions()
            layout.layoutDetailsPublisher = viewModel.document.layoutDetailsPublisher.receiveOnMain().eraseToAnyPublisher()
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
        super.setEditing(editing, animated: animated)
        collectionView.isEditing = editing
        bottomNavigationManager.multiselectActive(!editing)
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)

        if motion == .motionShake {
            shakeGestureStartDate = Date()
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
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
        case .editing:
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
    
    func reconfigure(items: [EditorItem]) {
        guard items.count > 0 else { return }

        var snapshot = dataSource.snapshot()
        let notExistingItems = items.filter { !snapshot.itemIdentifiers.contains($0) }
        
        // If we received an update for item not presented in a data source
        // probably the new item is a new view model for an existing block. So we have to check by ID.
        // Example: BlockFileViewModel -> BlockImageViewModel when uploading image into file block
        for item in notExistingItems {
            guard let itemId = item.id else { continue }
            guard let oldItem = snapshot.itemIdentifiers.first(where: { $0.id == itemId }) else {
                anytypeAssertionFailure("Not found old item in snapshot", info: ["item": item] )
                continue
            }
            guard let index = snapshot.indexOfItem(oldItem) else { continue }
            guard let previousItem = snapshot.itemIdentifiers[safe: index - 1] else {
                anytypeAssertionFailure("Not found previous item in snapshot", info: ["oldItem": oldItem] )
                continue
            }
            
            snapshot.deleteItems([oldItem])
            snapshot.insertItems([item], afterItem: previousItem)
        }
        
        let existingItems = items.filter { snapshot.itemIdentifiers.contains($0) }
        snapshot.reloadItems(existingItems)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func update(
        changes: CollectionDifference<EditorItem>?,
        allModels: [EditorItem],
        isRealData: Bool,
        completion: @escaping () -> Void
    ) {
        var blocksSnapshot = NSDiffableDataSourceSectionSnapshot<EditorItem>()
        blocksSnapshot.append(allModels)

        applyBlocksSectionSnapshot(
            blocksSnapshot,
            animatingDifferences: dataSourceAnimationEnabled,
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
    }

    func itemDidChangeFrame(item: EditorItem) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            dataSource.apply(dataSource.snapshot(), animatingDifferences: true)
        }
    }

    func blockDidFinishEditing() {
        self.firstResponderView = nil
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

        handleState(state: viewModel.blocksStateManager.editingState)
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
        navigationBarBackgroundView.backgroundColor = .Background.primary
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
    }
    
    func setupLayout() {
        view.addSubview(collectionView) {
            $0.pinToSuperview()
        }

        view.addSubview(blocksSelectionOverlayView) {
            $0.pinToSuperview()
        }
        if showHeader {
            view.addSubview(navigationBarBackgroundView) {
                $0.pinToSuperview(excluding: [.bottom])
            }
            view.addSubview(navigationBarView) {
                $0.pinToSuperview(excluding: [.bottom, .top])
                $0.top.equal(to: view.safeAreaLayoutGuide.topAnchor)
                $0.bottom.equal(to: navigationBarBackgroundView.bottomAnchor)
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
        
        viewModel.tapOnEmptyPlace()
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
                
                cell.contentConfiguration = block.makeContentConfiguration(maxWidth: collectionView.frame.width)
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

