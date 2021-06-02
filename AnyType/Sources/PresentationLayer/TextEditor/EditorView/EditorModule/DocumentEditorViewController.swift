import BlocksModels
import UIKit
import Combine
import FloatingPanel


final class DocumentEditorViewController: UIViewController {

    private enum Constants {
        static let headerReuseId = "header"
        static let cellIndentationWidth: CGFloat = 24
        static let cellReuseId: String = NSStringFromClass(UICollectionViewListCell.self)
    }

    private var dataSource: UICollectionViewDiffableDataSource<DocumentSection, BaseBlockViewModel>?
    private let viewModel: DocumentEditorViewModel
    
    private let collectionView: UICollectionView = {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.headerMode = .supplementary
        listConfiguration.backgroundColor = .white
        listConfiguration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        let collectionView = UICollectionView(frame: UIScreen.main.bounds,
                                               collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private var insetsHelper: ScrollViewContentInsetsHelper?
    
    private var subscriptions: Set<AnyCancellable> = []
    /// Gesture recognizer to handle taps in empty document
    private let listViewTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer: UITapGestureRecognizer = .init()
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()

    init(viewModel: DocumentEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.setNavigationItem(windowHolder?.rootNavigationController.navigationBar.topItem)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        insetsHelper = nil
        guard isMovingFromParent else { return }
        self.viewModel.applyPendingChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        insetsHelper = ScrollViewContentInsetsHelper(scrollView: collectionView)
    }

    private func setupUI() {
        setupCollectionView()
        setupCollectionViewDataSource()
        setupInteractions()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.pinAllEdges(to: view)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }


    private func setupCollectionViewDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BaseBlockViewModel> { [weak self] (cell, indexPath, item) in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }

        let codeCellRegistration = UICollectionView.CellRegistration<CodeBlockCellView, BaseBlockViewModel> { [weak self] (cell, indexPath, item) in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }

        let dataSource = UICollectionViewDiffableDataSource<DocumentSection, BaseBlockViewModel>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: BaseBlockViewModel) -> UICollectionViewCell? in
            if item is CodeBlockViewModel {
                return collectionView.dequeueConfiguredReusableCell(using: codeCellRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration
        <DocumentDetailsView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (detailsView, string, indexPath) in
            guard let viewModel = self?.viewModel.detailsViewModel else { return }

            detailsView.configure(model: viewModel)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] in
            return self?.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: $2)
        }
        
        self.dataSource = dataSource
    }

    private func setupCell(cell: UICollectionViewListCell, indexPath: IndexPath, item: BaseBlockViewModel) {
        cell.contentConfiguration = item.buildContentConfiguration()
        cell.indentationWidth = Constants.cellIndentationWidth
        cell.indentationLevel = item.indentationLevel()
        cell.contentView.isUserInteractionEnabled = !self.viewModel.selectionEnabled()

        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
    }

    private func setupInteractions() {
        self.configured()
        
        listViewTapGestureRecognizer.addTarget(self, action: #selector(tapOnListViewGestureRecognizerHandler))
        self.view.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }

    @objc private func tapOnListViewGestureRecognizerHandler() {
        if self.viewModel.selectionEnabled() {
            return
        }
        let location = self.listViewTapGestureRecognizer.location(in: self.listViewTapGestureRecognizer.view)
        if !self.collectionView.visibleCells.first(where: {$0.frame.contains(location)}).isNil {
            return
        }
        self.viewModel.handlingTapIfEmpty()
    }

    /// Add handlers to viewModel state changes
    private func configured() {
        self.viewModel.publicSizeDidChangePublisher.receiveOnMain().sink { [weak self] (value) in
            self?.updateView()
        }.store(in: &self.subscriptions)

        self.viewModel.updateElementsPublisher.sink { [weak self] value in
            self?.handleUpdateBlocks(blockIds: value)
        }.store(in: &self.subscriptions)

        self.viewModel.selectionHandler?.selectionEventPublisher().sink(receiveValue: { [weak self] value in
            self?.handleSelection(event: value)
        }).store(in: &self.subscriptions)
        
        viewModel.onDetailsViewModelUpdate = { [weak self] in
            self?.handleDetailsViewModelUpdate()
        }
    }

    private func handleUpdateBlocks(blockIds: Set<BlockId>) {
        guard let dataSource = dataSource else { return }

        let sectionSnapshot = dataSource.snapshot(for: .first)
        var snapshot = dataSource.snapshot()
        var itemsForUpdate = sectionSnapshot.visibleItems.filter { blockIds.contains($0.blockId) }
        let focusedViewModelIndex = itemsForUpdate.firstIndex(where: { viewModel -> Bool in
            guard let indexPath = dataSource.indexPath(for: viewModel) else { return false }
            return collectionView.cellForItem(at: indexPath)?.isAnySubviewFirstResponder() ?? false
        })
        if let index = focusedViewModelIndex {
            updateFocusedViewModel(viewModel: itemsForUpdate.remove(at: index))
        }
        if itemsForUpdate.isEmpty {
            return
        }
        snapshot.reloadItems(itemsForUpdate)
        apply(snapshot)
    }
    
    private func updateFocusedViewModel(viewModel: BaseBlockViewModel) {
        guard let indexPath = dataSource?.indexPath(for: viewModel) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }

        let textModel = viewModel as? TextBlockViewModel
        let focusPosition = textModel?.focusPosition()
        cell.indentationLevel = viewModel.indentationLevel()
        cell.contentConfiguration = viewModel.buildContentConfiguration()
        let prefferedSize = cell.systemLayoutSizeFitting(CGSize(width: cell.frame.size.width,
                                                                height: UIView.layoutFittingCompressedSize.height))
        if cell.frame.size.height != prefferedSize.height {
            updateView()
        }
        let focus = TextViewFocus(position: focusPosition)
        textModel?.set(focus: focus)
    }
    
    private func handleSelection(event: EditorSelectionIncomingEvent) {
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
    
    private func handleDetailsViewModelUpdate() {
        guard collectionView.numberOfSections > 0 else { return }
        guard var snapshot = dataSource?.snapshot() else { return }

        if let titleBlockView = snapshot.itemIdentifiers.first(where: { blockViewModel in
            guard blockViewModel.information.content.type == .text(.title) else {
                return false
            }
            return true
        }) {
            snapshot.reloadItems([titleBlockView])
            apply(snapshot)
        }
    }
        
    private func deselectAllBlocks() {
        self.collectionView.deselectAllSelectedItems()
        self.collectionView.visibleCells.forEach { $0.contentView.isUserInteractionEnabled = true }
    }
}

// MARK: - HeaderView PageDetails

extension DocumentEditorViewController {
    
    private func focusOnFocusedBlock() {
        guard let dataSource = self.dataSource else { return }
        let snapshot = dataSource.snapshot(for: .first)
        let userSession = viewModel.document.userSession
        if let id = userSession?.firstResponderId(), let focusedAt = userSession?.focusAt() {
            let itemIdentifiers = snapshot.visibleItems

            if let index = itemIdentifiers.firstIndex(where: { $0.blockId == id }),
               let textBlock = itemIdentifiers[index] as? TextBlockViewModel {
                textBlock.set(focus: .init(position: focusedAt))
            }
        }
    }
}

// MARK: - Initial Update data
extension DocumentEditorViewController {
    private func updateView() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
        
    private func apply(_ snapshot: NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>,
                       completion: (() -> Void)? = nil) {
        let selectedCells = collectionView.indexPathsForSelectedItems

        // For now animatingDifferences should be false otherwise some cells will not be reloading.
        self.dataSource?.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.updateVisibleNumberedItems()
            completion?()
            
            selectedCells?.forEach {
                self?.collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
            }
        }
    }
    
    private func applySnapshotAndSetFocus(_ snapshot: NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>) {
        apply(snapshot) { [weak self] in
            self?.focusOnFocusedBlock()
        }
    }
    
    private func updateVisibleNumberedItems() {
        self.collectionView.indexPathsForVisibleItems.forEach {
            guard let builder = self.viewModel.builders[safe: $0.row] else { return }
            let content = builder.getBlock().content
            guard case let .text(text) = content, text.contentType == .numbered else { return }
            self.collectionView.cellForItem(at: $0)?.contentConfiguration = builder.buildContentConfiguration()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension DocumentEditorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didSelectBlock(at: indexPath)
        if self.viewModel.selectionEnabled() {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if !self.viewModel.selectionEnabled() {
            return
        }
        self.viewModel.didSelectBlock(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let viewModel = dataSource?.itemIdentifier(for: indexPath) else { return false }
        if self.viewModel.selectionEnabled() {
            if case let .text(text) = viewModel.getBlock().content {
                return text.contentType != .title
            }
            return true
        }
        switch viewModel.getBlock().content {
        case .text:
            return false
        case let .file(file) where [.done, .uploading].contains(file.state):
            return false
        default:
            return true
        }
    }
}

// MARK: TODO: Remove later.
extension DocumentEditorViewController {
    func getViewModel() -> DocumentEditorViewModel { self.viewModel }
}

// MARK: - EditorModuleDocumentViewInput

extension DocumentEditorViewController: EditorModuleDocumentViewInput {
    func setFocus(at index: Int) {
        guard !self.viewModel.selectionEnabled() else { return }
        guard let snapshot = self.dataSource?.snapshot() else { return }

        let itemIdentifiers = snapshot.itemIdentifiers(inSection: .first)

        if let textItem = itemIdentifiers[index] as? TextBlockViewModel {
            let userSession = viewModel.document.userSession
            let focus = TextViewFocus(position: userSession?.focusAt() ?? .end)
            textItem.set(focus: focus)
        }
    }
    
    func updateData(_ rows: [BaseBlockViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>()
        snapshot.appendSections([.first])
        snapshot.appendItems(rows)
        applySnapshotAndSetFocus(snapshot)
    }

    func showCodeLanguageView(with languages: [String], completion: @escaping (String) -> Void) {
        let searchListViewController = SearchListViewController(items: languages, completion: completion)
        modalPresentationStyle = .pageSheet
        present(searchListViewController, animated: true)
    }

    func showStyleMenu(blockModel: BlockModelProtocol, blockViewModel: BaseBlockViewModel) {
        guard let viewControllerForPresenting = parent else { return }
        self.view.endEditing(true)

        BottomSheetsFactory.createStyleBottomSheet(parentViewController: viewControllerForPresenting,
                                                   delegate: self,
                                                   blockModel: blockModel) { [weak self] action in
            self?.viewModel.handleAction(action)
        }

        if let indexPath = dataSource?.indexPath(for: blockViewModel) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
    }
}

extension DocumentEditorViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidRemove(_ fpc: FloatingPanelController) {
        collectionView.deselectAllSelectedItems()
        
        guard let snapshot = self.dataSource?.snapshot() else { return }

        let userSession = viewModel.document.userSession
        let blockModel = userSession?.firstResponder()

        let itemIdentifiers = snapshot.itemIdentifiers(inSection: .first)

        let blockViewModel = itemIdentifiers.first { blockViewModel in
            blockViewModel.blockId == blockModel?.information.id
        }

        if let blockViewModel = blockViewModel as? TextBlockViewModel {
            let focus = TextViewFocus(position: userSession?.focusAt() ?? .end)
            blockViewModel.set(focus: focus)
        }
    }
}
