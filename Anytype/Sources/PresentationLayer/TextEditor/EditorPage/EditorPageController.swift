import BlocksModels
import UIKit
import Combine
import AnytypeCore

import SwiftUI
import Amplitude

final class EditorPageController: UIViewController {

    weak var browserViewInput: EditorBrowserViewInputProtocol?
    private(set) lazy var dataSource = makeCollectionViewDataSource()
    
    private lazy var deletedScreen = EditorPageDeletedScreen(
        onBackTap: viewModel.router.goBack
    )
    
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
        collectionView.contentInsetAdjustmentBehavior = .always

        return collectionView
    }()
    
    private(set) var insetsHelper: ScrollViewContentInsetsHelper?
    private var contentOffset: CGPoint = .zero
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

    private lazy var longTapGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(EditorPageController.handleLongPress))

        recognizer.minimumPressDuration = 0.5
        return recognizer
    }()

    private lazy var navigationBarHelper = EditorNavigationBarHelper(
        onSettingsBarButtonItemTap: { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.viewModel.showSettings()
        }
    )

    private let blocksSelectionOverlayView: BlocksSelectionOverlayView
    
    var viewModel: EditorPageViewModelProtocol!
    private var cancellables = [AnyCancellable]()
    
    // MARK: - Initializers
    init(blocksSelectionOverlayView: BlocksSelectionOverlayView) {
        self.blocksSelectionOverlayView = blocksSelectionOverlayView

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
        
        navigationBarHelper.handleViewWillAppear(controllerForNavigationItems, collectionView)
        
        insetsHelper = ScrollViewContentInsetsHelper(
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
        
        viewModel.viewWillDisappear()
        
        navigationBarHelper.handleViewWillDisappear()
        insetsHelper = nil
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.isEditing = editing
        browserViewInput?.multiselectActive(!editing)
    }
    
    private var controllerForNavigationItems: UIViewController? {
        guard parent is UINavigationController else {
            return parent
        }
        
        return self
    }

    func bindViewModel() {
        viewModel.blocksStateManager.editorEditingState.sink { [unowned self] state in
            switch state {
            case .selecting(let blockIds):
                view.endEditing(true)
                setEditing(false, animated: true)
                blockIds.forEach(selectBlock)
                blocksSelectionOverlayView.isHidden = false
                navigationBarHelper.canChangeSyncStatusAppearance = false
                navigationBarHelper.setNavigationBarHidden(true)
            case .editing:
                collectionView.deselectAllMovingItems()
                dividerCursorController.movingMode = .none
                setEditing(true, animated: true)
                blocksSelectionOverlayView.isHidden = true
                navigationBarHelper.setNavigationBarHidden(false)
                navigationBarHelper.canChangeSyncStatusAppearance = true
            case .moving(let indexPaths):
                dividerCursorController.movingMode = .drum
                setEditing(false, animated: true)
                indexPaths.forEach { indexPath in
                    collectionView.deselectItem(at: indexPath, animated: false)
                    collectionView.setItemIsMoving(true, at: indexPath)
                }
            }
        }.store(in: &cancellables)
    }
}

// MARK: - EditorPageViewInput

extension EditorPageController: EditorPageViewInput {
    func update(header: ObjectHeader, details: ObjectDetails?) {
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<EditorItem>()
        headerSnapshot.append([.header(header)])

        if #available(iOS 15.0, *) {
            dataSource.apply(headerSnapshot, to: .header, animatingDifferences: false)
        } else {
            UIView.performWithoutAnimation {
                dataSource.apply(headerSnapshot, to: .header, animatingDifferences: true)
            }
        }

        navigationBarHelper.configureNavigationBar(
            using: header,
            details: details
        )
    }
    
    func update(syncStatus: SyncStatus) {
        navigationBarHelper.updateSyncStatus(syncStatus)
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

        applyBlocksSectionSnapshot(blocksSnapshot)
    }

    func selectBlock(blockId: BlockId) {
        if let item = dataSourceItem(for: blockId),
            let indexPath = dataSource.indexPath(for: item) {
            viewModel.modelsHolder.contentProvider(for: item)
                .map(reloadCell(for:))

            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }

        collectionView.indexPathsForSelectedItems.map(
            viewModel.blocksStateManager.didUpdateSelectedIndexPaths
        )
    }
    
    func textBlockWillBeginEditing() {
        contentOffset = collectionView.contentOffset
    }
    
    func textBlockDidBeginEditing() {
//        collectionView.setContentOffset(contentOffset, animated: false)
    }

    func textBlockDidChangeFrame() {
        // Can be skipped now. But need to clarify if every iOS version is adapted for automatic layout invalidation.
//        UIView.animate(withDuration: 0.3) {
//            self.collectionView.collectionViewLayout.invalidateLayout()
//        }
    }

    func textBlockDidChangeText() {
        // For future changes
    }

    func showDeletedScreen(_ show: Bool) {
        navigationBarHelper.setNavigationBarHidden(show)
        deletedScreen.isHidden = !show
        if show { UIApplication.shared.hideKeyboard() }
    }

    func blockDidFinishEditing(blockId: BlockId) {
        guard let newItem = viewModel.modelsHolder.contentProvider(for: blockId) else { return }

        reloadCell(for: .block(newItem))
    }
}

// MARK: - Private extension

private extension EditorPageController {
    
    func setupView() {
        view.backgroundColor = .backgroundPrimary
        
        setupCollectionView()
        
        setupInteractions()
        
        setupLayout()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        collectionView.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }
    
    func setupInteractions() {
        listViewTapGestureRecognizer.addTarget(
            self,
            action: #selector(tapOnListViewGestureRecognizerHandler)
        )
        view.addGestureRecognizer(listViewTapGestureRecognizer)

        collectionView.addGestureRecognizer(longTapGestureRecognizer)
    }
    
    func setupLayout() {
        view.addSubview(collectionView) {
            $0.pinToSuperview()
        }
        view.addSubview(deletedScreen) {
            $0.pinToSuperview()
        }

        navigationBarHelper.addFakeNavigationBarBackgroundView(to: view)

        view.addSubview(blocksSelectionOverlayView) {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: view.safeAreaLayoutGuide.bottomAnchor)
        }

        blocksSelectionOverlayView.isHidden = true

        deletedScreen.isHidden = true
    }

    func reloadCell(for item: EditorItem) {
        guard let indexPath = dataSource.indexPath(for: item),
              let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }

        switch item {
        case .header: break
        case .block(let blockViewModel):
            cell.contentConfiguration = blockViewModel.makeContentConfiguration(maxWidth: cell.bounds.width)
            cell.indentationLevel = blockViewModel.indentationLevel 
        case .system(let systemContentConfiguationProvider):
            cell.contentConfiguration = systemContentConfiguationProvider.makeContentConfiguration(maxWidth: cell.bounds.width)
            cell.indentationLevel = systemContentConfiguationProvider.indentationLevel 
        }
    }



    func dataSourceItem(for blockId: BlockId) -> EditorItem? {
        dataSource.snapshot().itemIdentifiers.first {
            switch $0 {
            case let .block(block):
                return block.information.id == blockId
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

        guard gesture.state == .ended else { return }

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
            }


            return cell
        }

        var initialSnapshot = NSDiffableDataSourceSnapshot<EditorSection, EditorItem>()
        initialSnapshot.appendSections(EditorSection.allCases)
        
        dataSource.apply(initialSnapshot, animatingDifferences: false)
        
        return dataSource
    }
    
    func createHeaderCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, ObjectHeader> {
        .init { [weak self] cell, _, item in
            guard let self = self else { return }

            let topAdjustedContentInset = self.collectionView.adjustedContentInset.top

            if var objectHeaderFilledConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width) as? ObjectHeaderFilledConfiguration {
                objectHeaderFilledConfiguration.topAdjustedContentInset = topAdjustedContentInset
                cell.contentConfiguration = objectHeaderFilledConfiguration
            }
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
            cell.indentationWidth = Constants.cellIndentationWidth
            cell.indentationLevel = item.indentationLevel
        }
    }
    
    func setupCell(cell: UICollectionViewListCell, indexPath: IndexPath, item: BlockViewModelProtocol) {
        cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        cell.indentationWidth = Constants.cellIndentationWidth
        cell.indentationLevel = item.indentationLevel
        cell.contentView.isUserInteractionEnabled = true
        
        cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        if FeatureFlags.rainbowViews {
            cell.fillSubviewsWithRandomColors(recursively: false)
        }
    }
    
}

// MARK: - Initial Update data

private extension EditorPageController {
    
    func applyBlocksSectionSnapshot(_ snapshot: NSDiffableDataSourceSectionSnapshot<EditorItem>) {
        let selectedCells = collectionView.indexPathsForSelectedItems
        dataSource.apply(snapshot, to: .main, animatingDifferences: false)
        selectedCells?.forEach {
            self.collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
        }
    }
}


// MARK: - Constants

private extension EditorPageController {
    
    enum Constants {
        static let cellIndentationWidth: CGFloat = 24
    }
    
}
