import Services
import UIKit
import Combine
import AnytypeCore
import SwiftUI

final class EditorPageController: UIViewController {
    
    let bottomNavigationManager: EditorBottomNavigationManagerProtocol
    private(set) weak var browserViewInput: EditorBrowserViewInputProtocol?
    private(set) lazy var dataSource = makeCollectionViewDataSource()
    private weak var firstResponderView: UIView?

    let collectionView: EditorCollectionView = {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.backgroundColor = .clear
        listConfiguration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
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

    @Published var offsetDidChanged: CGPoint = .zero

    private lazy var longTapGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(EditorPageController.handleLongPress))

        recognizer.minimumPressDuration = 0.3
        return recognizer
    }()

    private lazy var navigationBarHelper: EditorNavigationBarHelper = EditorNavigationBarHelper(
        viewController: self,
        onSettingsBarButtonItemTap: { [weak viewModel] in
            UISelectionFeedbackGenerator().selectionChanged()
            viewModel?.showSettings()
        },
        onDoneBarButtonItemTap:  { [weak viewModel] in
            viewModel?.blocksStateManager.didSelectEditingMode()
        }
    )

    private let blocksSelectionOverlayView: BlocksSelectionOverlayView
    
    var viewModel: EditorPageViewModelProtocol! {
        didSet {
            viewModel.setupSubscriptions()
        }
    }

    private var selectingRangeEditorItem: EditorItem?
    private var selectingRangeTextView: UITextView?

    private var cancellables = [AnyCancellable]()
    
    // MARK: - Initializers
    init(
        blocksSelectionOverlayView: BlocksSelectionOverlayView,
        bottomNavigationManager: EditorBottomNavigationManagerProtocol,
        browserViewInput: EditorBrowserViewInputProtocol?
    ) {
        self.blocksSelectionOverlayView = blocksSelectionOverlayView
        self.bottomNavigationManager = bottomNavigationManager
        self.browserViewInput = browserViewInput

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

        viewModel.viewDidLoad()
        bindViewModel()
        setEditing(true, animated: false)
        collectionView.allowsSelectionDuringEditing = true

        navigationBarHelper.handleViewWillAppear(scrollView: collectionView)

        AnytypeWindow.shared?.textRangeTouchSubject.sink { [weak self] touch in
            self?.handleTextSelectionTouch(touch)
        }.store(in: &cancellables)
    }

    private func performBlocksSelection(with touch: UITouch) {
        guard let indexPath = collectionView.indexPath(for: touch) else {
            return
        }

        selectItem(at: indexPath)
    }

    private func selectItem(at indexPath: IndexPath, animated: Bool = true) {
        guard viewModel.blocksStateManager.canSelectBlock(at: indexPath) else {
            return
        }

        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            return
        }

        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        collectionView.indexPathsForSelectedItems.map {
            viewModel.blocksStateManager.didUpdateSelectedIndexPaths($0)
        }
    }

    private func handleTextSelectionTouch(_ touch: UITouch) {
        switch viewModel.blocksStateManager.editingState {
        case .selecting:
            performBlocksSelection(with: touch)
        case .editing:
            guard let selectingRangeEditorItem = selectingRangeEditorItem,
                  selectingRangeEditorItem.canHandleTextRangeTouch,
                  let sourceTextIndexPath = dataSource.indexPath(for: selectingRangeEditorItem),
                  let cell = collectionView.cellForItem(at: sourceTextIndexPath) else {
                return
            }
            let pointInCell = touch.location(in: cell)
            let isAscendingTouch = pointInCell.y > cell.center.y
            let threshold: CGFloat = isAscendingTouch ? Constants.selectingTextThreshold : -Constants.selectingTextThreshold
            var locationInCollectionView = touch.location(in: collectionView)

            locationInCollectionView.y = locationInCollectionView.y + threshold

            guard let touchingIndexPath = collectionView.indexPathForItem(at: locationInCollectionView),
                  let touchingItem = dataSource.itemIdentifier(for: touchingIndexPath),
                  touchingItem != selectingRangeEditorItem,
                  let selectingRangeTextView = selectingRangeTextView,
                  let sourceTextIndexPath = dataSource.indexPath(for: selectingRangeEditorItem)
            else {
                return
            }

            let isValidForDescending = selectingRangeTextView.textViewSelectionPosition.contains(.start) &&
                            sourceTextIndexPath.compare(touchingIndexPath) == .orderedDescending

            let isValidForAscending = selectingRangeTextView.textViewSelectionPosition.contains(.end) &&
                            sourceTextIndexPath.compare(touchingIndexPath) == .orderedAscending

            if isValidForAscending || isValidForDescending {
                UIApplication.shared.hideKeyboard()
                viewModel.blocksStateManager.didSelectSelection(from: sourceTextIndexPath)
                selectItem(at: touchingIndexPath)
            }
        default: break
        }
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
        browserViewInput?.didShow(collectionView: collectionView)
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
            viewModel.shakeMotionDidAppear()

            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
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
        viewModel.blocksStateManager.editorEditingStatePublisher.sink { [weak self] state in
            self?.handleState(state: state)
        }.store(in: &cancellables)

        viewModel.blocksStateManager.editorSelectedBlocks.sink { [weak self] blockIds in
            guard let self else { return }
            blockIds.forEach(selectBlock)
        }.store(in: &cancellables)
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        view.endEditing(true)

        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

// MARK: - EditorPageViewInput

extension EditorPageController: EditorPageViewInput {
    var contentOffsetDidChangedStatePublisher: AnyPublisher<CGPoint, Never> {
        $offsetDidChanged.eraseToAnyPublisher()
    }

    func visibleRect(to view: UIView) -> CGRect {
        return collectionView.convert(collectionView.bounds, to: view)
    }

    func update(header: ObjectHeader, details: ObjectDetails?) {
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<EditorItem>()
        headerSnapshot.append([.header(header)])
        if #available(iOS 15.0, *) {
            dataSource.apply(headerSnapshot, to: .header, animatingDifferences: true)

        } else {
            UIView.performWithoutAnimation {
                dataSource.apply(headerSnapshot, to: .header, animatingDifferences: true)
            }
        }

        navigationBarHelper.configureNavigationBar(using: header, details: details)
    }
    
    func update(syncStatus: SyncStatus) {
        navigationBarHelper.updateSyncStatus(syncStatus)
    }

    func update(changes: CollectionDifference<EditorItem>?) {
        let currentSnapshot = dataSource.snapshot(for: .main)

        if let changes = changes {
            for change in changes.insertions {
                guard currentSnapshot.isVisible(change.element) else { continue }

                reloadCell(for: change.element)
            }
        }
    }

    func didSelectTextRangeSelection(blockId: BlockId, textView: UITextView) {
        if let item = dataSourceItem(for: blockId), textView.textViewSelectionPosition.contains(.end) || textView.textViewSelectionPosition.contains(.start) {
            self.selectingRangeEditorItem = item
            self.selectingRangeTextView = textView
        }
    }

    func update(
        changes: CollectionDifference<EditorItem>?,
        allModels: [EditorItem]
    ) {
        var blocksSnapshot = NSDiffableDataSourceSectionSnapshot<EditorItem>()
        blocksSnapshot.append(allModels)

        if let changes = changes {
            for change in changes.insertions {
                guard blocksSnapshot.isVisible(change.element) else { continue }

                reloadCell(for: change.element)
            }
        }

        let animatingDifferences = changes?.canPerformAnimation ?? true
        applyBlocksSectionSnapshot(blocksSnapshot, animatingDifferences: animatingDifferences)
    }

    func scrollToBlock(blockId: BlockId) {
        guard let item = dataSourceItem(for: blockId),
              let indexPath = dataSource.indexPath(for: item),
              let cellRect = collectionView.layoutAttributesForItem(at: indexPath)?.frame else { return }
        let yOffset = cellRect.minY - view.safeAreaInsets.top
        collectionView.setContentOffset(.init(x: 0, y: yOffset), animated: true)
    }
    
    func selectBlock(blockId: BlockId) {
        if let item = dataSourceItem(for: blockId),
            let indexPath = dataSource.indexPath(for: item) {
            viewModel.modelsHolder.contentProvider(for: item)
                .map(reloadCell(for:))

            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])

            collectionView.indexPathsForSelectedItems.map(
                viewModel.blocksStateManager.didUpdateSelectedIndexPaths
            )
        }
    }
    
    func textBlockWillBeginEditing() { }
    func textBlockDidBeginEditing(firstResponderView: UIView) {
        self.firstResponderView = firstResponderView
    }

    func blockDidChangeFrame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let currentSnapshot = self.dataSource.snapshot()
            self.dataSource.apply(currentSnapshot, animatingDifferences: true)
        }
    }

    func textBlockDidChangeText() {
        // For future changes
    }

    func blockDidFinishEditing(blockId: BlockId) {
        self.selectingRangeTextView = nil
        self.selectingRangeEditorItem = nil

        viewModel.didFinishEditing(blockId: blockId)
        
        guard let newItem = viewModel.modelsHolder.contentProvider(for: blockId) else { return }

        reloadCell(for: .block(newItem))

        var blocksSnapshot = NSDiffableDataSourceSectionSnapshot<EditorItem>()
        blocksSnapshot.append(viewModel.modelsHolder.items)
        applyBlocksSectionSnapshot(blocksSnapshot, animatingDifferences: false)
    }

    // MARK: -
    // Need to merge those 3 methods with editing state publisher!!!
    func endEditing() {
        view.endEditing(true)
        collectionView.isEditing = false
    }

    func adjustContentOffset(relatively: UIView) {
        collectionView.adjustContentOffsetForSelectedItem(relatively: relatively)
    }

    // Moved from EditorPageController+FloatingPanelControllerDelegate.swift
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
            $0.pinToSuperviewPreservingReadability()
        }

        navigationBarHelper.addFakeNavigationBarBackgroundView(to: view)

        view.addSubview(blocksSelectionOverlayView) {
            $0.pinToSuperview()
        }

        blocksSelectionOverlayView.isHidden = true
    }

    func reloadCell(for item: EditorItem) {
        guard let indexPath = dataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }

        switch item {
        case .header: break
        case .block(let blockViewModel):
            cell.contentConfiguration = blockViewModel.makeContentConfiguration(maxWidth: cell.bounds.width)
        case .system(let systemContentConfiguationProvider):
            cell.contentConfiguration = systemContentConfiguationProvider.makeContentConfiguration(maxWidth: cell.bounds.width)
        }
    }

    func dataSourceItem(for blockId: BlockId) -> EditorItem? {
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
        guard collectionView.isEditing && dividerCursorController.movingMode != .drum else { return }
        let location = self.listViewTapGestureRecognizer.location(in: collectionView)
        let cellIndexPath = collectionView.indexPathForItem(at: location)
        guard cellIndexPath == nil else { return }
        
        viewModel.actionHandler.createEmptyBlock(parentId: viewModel.document.objectId)
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
    
    func createCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, BlockViewModelProtocol> {
        .init { [weak self] cell, indexPath, item in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }
    }
    
    func createSystemCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, SystemContentConfiguationProvider> {
        .init { (cell, indexPath, item) in
            cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        }
    }
    
    func setupCell(cell: UICollectionViewListCell, indexPath: IndexPath, item: BlockViewModelProtocol) {
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
        animatingDifferences: Bool
    ) {
        if #available(iOS 15.0, *) {
            dataSource.apply(snapshot, to: .main, animatingDifferences: animatingDifferences)
        } else {
            UIView.performWithoutAnimation {
                dataSource.apply(snapshot, to: .main, animatingDifferences: true)
            }
        }

        let selectedCells = collectionView.indexPathsForSelectedItems
        selectedCells?.forEach {
            self.collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
        }
    }
}

extension UICollectionView {
    func indexPath(for touch: UITouch) -> IndexPath? {
        let point = touch.location(in: self)

        return indexPathForItem(at: point)
    }
}

private enum Constants {
    static let selectingTextThreshold: CGFloat = 30
}

