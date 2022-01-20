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
    private var firstResponderHelper: FirstResponderHelper?
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
        
        firstResponderHelper = FirstResponderHelper(scrollView: collectionView)
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
        firstResponderHelper = nil
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
                navigationBarHelper.setNavigationBarHidden(true)
            case .editing:
                collectionView.deselectAllMovingItems()
                dividerCursorController.movingMode = .none
                setEditing(true, animated: true)
                blocksSelectionOverlayView.isHidden = true
                navigationBarHelper.setNavigationBarHidden(false)
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
        changes: CollectionDifference<BlockViewModelProtocol>?,
        allModels: [BlockViewModelProtocol]
    ) {
        var blocksSnapshot = NSDiffableDataSourceSectionSnapshot<EditorItem>()
        blocksSnapshot.append(allModels.map { EditorItem.block($0) })

        var changedIndexes = [BlockId]()

        if let changes = changes {
            for change in changes.insertions {
                changedIndexes.append(change.element.blockId)

                guard let viewModel = allModels[safe: change.offset],
                      let item = blocksSnapshot.items[safe: change.offset],
                      blocksSnapshot.isVisible(item) else { continue }

                guard let indexPath = dataSource.indexPath(for: item) else { continue }
                guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }


                cell.contentConfiguration = viewModel.makeContentConfiguration(maxWidth: cell.bounds.width)
                cell.indentationLevel = viewModel.indentationLevel
            }
        }


        applyBlocksSectionSnapshot(blocksSnapshot)
    }

    func selectBlock(blockId: BlockId) {
        let item = dataSource.snapshot().itemIdentifiers.first {
            switch $0 {
            case let .block(block):
                return block.information.id == blockId
            case .header:
                return false
            }
        }
        
        if let item = item {
            let indexPath = dataSource.indexPath(for: item)
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
        collectionView.setContentOffset(contentOffset, animated: false)
    }

    func textBlockDidChangeFrame() {
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func textBlockDidChangeText() {
        // For future changes
    }

    func showDeletedScreen(_ show: Bool) {
        navigationBarHelper.setNavigationBarHidden(show)
        deletedScreen.isHidden = !show
        if show { UIApplication.shared.hideKeyboard() }
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
    
    @objc
    func tapOnListViewGestureRecognizerHandler() {
        guard collectionView.isEditing && dividerCursorController.movingMode != .drum else { return }
        let location = self.listViewTapGestureRecognizer.location(in: collectionView)
        let cellIndexPath = collectionView.indexPathForItem(at: location)
        guard cellIndexPath == nil else { return }
        
        viewModel.actionHandler.createEmptyBlock(parentId: nil)
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
        let codeCellRegistration = createCodeCellRegistration()
        
        let dataSource = UICollectionViewDiffableDataSource<EditorSection, EditorItem>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, dataSourceItem) -> UICollectionViewCell? in
            let cell: UICollectionViewCell
            switch dataSourceItem {
            case let .block(block):
                guard case .text(.code) = block.content.type else {
                    cell = collectionView.dequeueConfiguredReusableCell(
                        using: cellRegistration,
                        for: indexPath,
                        item: block
                    )

                    break
                }
                
                cell =  collectionView.dequeueConfiguredReusableCell(
                    using: codeCellRegistration,
                    for: indexPath,
                    item: block
                )
            case let .header(header):
                return collectionView.dequeueConfiguredReusableCell(
                    using: headerCellRegistration,
                    for: indexPath,
                    item: header
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
    
    func createHeaderCellRegistration()-> UICollectionView.CellRegistration<EditorViewListCell, ObjectHeader> {
        .init { cell, _, item in
            cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        }
    }
    
    func createCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, BlockViewModelProtocol> {
        .init { [weak self] cell, indexPath, item in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }
    }
    
    func createCodeCellRegistration() -> UICollectionView.CellRegistration<EditorViewListCell, BlockViewModelProtocol> {
        .init { [weak self] (cell, indexPath, item) in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }
    }
    
    func setupCell(cell: UICollectionViewListCell, indexPath: IndexPath, item: BlockViewModelProtocol) {
        cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        cell.indentationWidth = Constants.cellIndentationWidth
        cell.indentationLevel = item.indentationLevel
        cell.contentView.isUserInteractionEnabled = true
        
        cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        if FeatureFlags.rainbowCells {
            cell.fillSubviewsWithRandomColors(recursively: false)
        }
    }
    
}

// MARK: - Initial Update data

private extension EditorPageController {
    
    func applyBlocksSectionSnapshot(_ snapshot: NSDiffableDataSourceSectionSnapshot<EditorItem>) {
        let selectedCells = collectionView.indexPathsForSelectedItems

        UIView.performWithoutAnimation { [weak self] in
            guard let self = self else { return }

            self.dataSource.apply(snapshot, to: .main, animatingDifferences: true)
            self.focusOnFocusedBlock()
            selectedCells?.forEach {
                self.collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
            }
        }
    }
    
    private func focusOnFocusedBlock() {
        let userSession = UserSession.shared
        #warning("we should move this logic to TextBlockViewModel")
        if let id = userSession.firstResponderId.value, let focusedAt = userSession.focus.value,
           let blockViewModel = viewModel.modelsHolder.models.first(where: { $0.blockId == id }) as? TextBlockViewModel {
            blockViewModel.set(focus: focusedAt)
        }
    }
}


// MARK: - Constants

private extension EditorPageController {
    
    enum Constants {
        static let cellIndentationWidth: CGFloat = 24
    }
    
}
