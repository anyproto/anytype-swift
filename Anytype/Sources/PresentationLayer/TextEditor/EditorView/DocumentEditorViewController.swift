import BlocksModels
import UIKit
import Combine
import AnytypeCore

import SwiftUI
import Amplitude

final class DocumentEditorViewController: UIViewController {
    
    private(set) lazy var dataSource = makeCollectionViewDataSource()
        
    let collectionView: UICollectionView = {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.backgroundColor = .clear
        listConfiguration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never

        return collectionView
    }()
    
    private var insetsHelper: ScrollViewContentInsetsHelper?
    private var firstResponderHelper: FirstResponderHelper?
    private var contentOffset: CGPoint = .zero
    
    private var selectionSubscription: AnyCancellable?
    // Gesture recognizer to handle taps in empty document
    private let listViewTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer: UITapGestureRecognizer = .init()
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()

    private lazy var navigationBarHelper = EditorNavigationBarHelper(
        onBackBarButtonItemTap: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        },
        onSettingsBarButtonItemTap: { [weak self] in
            UISelectionFeedbackGenerator().selectionChanged()
            self?.viewModel.showSettings()
        }
    )
    
    private var objectHeaderViewTopConstraint: NSLayoutConstraint!
    private let objectHeaderView = ObjectHeaderView()

    var viewModel: DocumentEditorViewModelProtocol!

    // MARK: - Initializers
    
    init() {
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

        viewModel.viewLoaded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationBarHelper.handleViewWillAppear(controllerForNavigationItems, collectionView)
                
        firstResponderHelper = FirstResponderHelper(scrollView: collectionView)
        insetsHelper = ScrollViewContentInsetsHelper(
            scrollView: collectionView
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationBarHelper.handleViewWillDisappear()
        insetsHelper = nil
        firstResponderHelper = nil
    }
    
    private var controllerForNavigationItems: UIViewController? {
        guard parent is UINavigationController else {
            return parent
        }

        return self
    }
    
    func hnadleCollectionViewContentOffsetChange() {
        let contentOffsetY = collectionView.contentOffset.y
        let contentInsetTop = collectionView.contentInset.top

        let relativeYOffset = contentOffsetY + contentInsetTop - objectHeaderView.baseHeight

        let relativeHeight = -relativeYOffset

        objectHeaderViewTopConstraint.constant = -relativeYOffset
        objectHeaderView.heightConstraint.constant = max(relativeHeight, objectHeaderView.baseHeight)
    }
    
}

// MARK: - DocumentEditorViewInput

extension DocumentEditorViewController: DocumentEditorViewInput {
    
    func updateHeader(_ header: ObjectHeader, details: DetailsDataProtocol?) {
        objectHeaderView.configure(model: header)
        
        navigationBarHelper.configureNavigationBar(
            using: header,
            details: details
        )
    }
    
    func updateBlocks(_ blocks: [BlockViewModelProtocol]) {
        var snapshot = NSDiffableDataSourceSnapshot<ObjectSection, DataSourceItem>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(
            blocks.map { DataSourceItem.block($0) },
            toSection: .main
        )
        
        let sectionSnapshot = self.dataSource.snapshot(for: .main)
        
        sectionSnapshot.visibleItems.forEach { item in
            switch item {
            case let .block(block):
                let blockForUpdate = blocks.first { $0.blockId == block.blockId }

                guard let blockForUpdate = blockForUpdate else { return }
                guard let indexPath = self.dataSource.indexPath(for: item) else { return }
                guard let cell = self.collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }
                
                cell.contentConfiguration = blockForUpdate.makeContentConfiguration(maxWidth: cell.bounds.width)
                cell.indentationLevel = blockForUpdate.indentationLevel
            }
        }
        
        apply(snapshot) { [weak self] in
            guard let self = self else { return }
            self.focusOnFocusedBlock()
        }
    }
 
    func selectBlock(blockId: BlockId) {
        let item = dataSource.snapshot().itemIdentifiers.first {
            switch $0 {
            case let .block(block):
                return block.information.id == blockId
            }
        }
        
        if let item = item {
            let indexPath = dataSource.indexPath(for: item)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        updateView()
    }

    func needsUpdateLayout() {
        updateView()
    }

    func textBlockWillBeginEditing() {
        contentOffset = collectionView.contentOffset
    }
    
    func textBlockDidBeginEditing() {
        collectionView.setContentOffset(contentOffset, animated: false)
    }
    
    private func updateView() {
        UIView.performWithoutAnimation {
            dataSource.refresh(animatingDifferences: true)
        }
    }

}

// MARK: - Private extension

private extension DocumentEditorViewController {
    
    func setupView() {
        objectHeaderView.onBaseHeightUpdate = { [weak self] height in
            guard let self = self else { return }
            
            self.collectionView.contentInset.top = height
            self.collectionView.contentOffset = CGPoint(x: 0, y: -height)
            self.hnadleCollectionViewContentOffsetChange()
        }
        
        setupCollectionView()
        
        setupInteractions()
        
        setupLayout()
        navigationBarHelper.addFakeNavigationBarBackgroundView(to: view)
    }

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }
    
    func setupInteractions() {
        selectionSubscription = viewModel
            .selectionHandler
            .selectionEventPublisher()
            .sink { [weak self] value in
                self?.handleSelection(event: value)
            }
        
        listViewTapGestureRecognizer.addTarget(
            self,
            action: #selector(tapOnListViewGestureRecognizerHandler)
        )
        view.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }
    
    func setupLayout() {
        view.addSubview(objectHeaderView) {
            objectHeaderViewTopConstraint = $0.bottom.equal(to: view.topAnchor)
            $0.pinToSuperview(excluding: [.top, .bottom])
        }
        
        view.addSubview(collectionView) {
            $0.pinToSuperview()
        }
    }
    
    @objc
    func tapOnListViewGestureRecognizerHandler() {
        if viewModel.selectionHandler.selectionEnabled == true { return }
        
        let location = self.listViewTapGestureRecognizer.location(in: collectionView)
        let cellIndexPath = collectionView.indexPathForItem(at: location)
        guard cellIndexPath == nil else { return }

        viewModel.blockActionHandler.onEmptySpotTap()
    }
    
    func handleSelection(event: EditorSelectionIncomingEvent) {
        switch event {
        case .selectionDisabled:
            deselectAllBlocks()
        case let .selectionEnabled(event):
            switch event {
            case .isEmpty:
                deselectAllBlocks()
            case let .nonEmpty(count, _):
                // We always count with this "1" because of top title block, which is not selectable
                if count == collectionView.numberOfItems(inSection: 0) - 1 {
                    collectionView.selectAllItems(startingFrom: 1)
                }
            }
            collectionView.visibleCells.forEach { $0.contentView.isUserInteractionEnabled = false }
        }
    }
        
    func deselectAllBlocks() {
        self.collectionView.deselectAllSelectedItems()
        self.collectionView.visibleCells.forEach { $0.contentView.isUserInteractionEnabled = true }
    }
    
    func makeCollectionViewDataSource() -> UICollectionViewDiffableDataSource<ObjectSection, DataSourceItem> {
        let cellRegistration = createCellRegistration()
        let codeCellRegistration = createCodeCellRegistration()

        let dataSource = UICollectionViewDiffableDataSource<ObjectSection, DataSourceItem>(
            collectionView: collectionView
        ) { (collectionView, indexPath, dataSourceItem) -> UICollectionViewCell? in
            switch dataSourceItem {
            case let .block(block):
                guard case .text(.code) = block.content.type else {
                    return collectionView.dequeueConfiguredReusableCell(
                        using: cellRegistration,
                        for: indexPath,
                        item: block
                    )
                }
                
                return collectionView.dequeueConfiguredReusableCell(
                    using: codeCellRegistration,
                    for: indexPath,
                    item: block
                )
            }
        }
        
        return dataSource
    }
    
    func createCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, BlockViewModelProtocol> {
        .init { [weak self] cell, indexPath, item in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }
    }
    
    func createCodeCellRegistration() -> UICollectionView.CellRegistration<CodeBlockCellView, BlockViewModelProtocol> {
        .init { [weak self] (cell, indexPath, item) in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }
    }

    func setupCell(cell: UICollectionViewListCell, indexPath: IndexPath, item: BlockViewModelProtocol) {
        cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        cell.indentationWidth = Constants.cellIndentationWidth
        cell.indentationLevel = item.indentationLevel
        cell.contentView.isUserInteractionEnabled = !viewModel.selectionHandler.selectionEnabled

        cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        if FeatureFlags.rainbowCells {
            cell.fillSubviewsWithRandomColors(recursively: false)
        }
    }

}

// MARK: - Initial Update data

extension DocumentEditorViewController {
        
    private func apply(
        _ snapshot: NSDiffableDataSourceSnapshot<ObjectSection, DataSourceItem>,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let selectedCells = collectionView.indexPathsForSelectedItems

        UIView.performWithoutAnimation {
            self.dataSource.apply(
                snapshot,
                animatingDifferences: animatingDifferences
            ) { [weak self] in
                completion?()

                selectedCells?.forEach {
                    self?.collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
                }
            }
        }
    }

    private func focusOnFocusedBlock() {
        let userSession = viewModel.document.userSession
        // TODO: we should move this logic to TextBlockViewModel
        if let id = userSession?.firstResponder?.information.id, let focusedAt = userSession?.focus,
           let blockViewModel = viewModel.modelsHolder.models.first(where: { $0.blockId == id }) as? TextBlockViewModel {
            blockViewModel.set(focus: focusedAt)
        }
    }
}


// MARK: - Constants

private extension DocumentEditorViewController {
    
    enum Constants {
        static let cellIndentationWidth: CGFloat = 24
    }
    
}

struct DocumentEditorViewController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

struct DocumentEditorViewController_Previews_2: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
