import BlocksModels
import UIKit
import Combine
import FloatingPanel
import SwiftUI

final class DocumentEditorViewController: UIViewController {
    
    private lazy var dataSource = makeCollectionViewDataSource()
    
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
    private var contentOffset: CGPoint = .zero
    
    private var subscriptions: Set<AnyCancellable> = []
    // Gesture recognizer to handle taps in empty document
    private let listViewTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer: UITapGestureRecognizer = .init()
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()

    private let viewModel: DocumentEditorViewModel

    // MARK: - Initializers
    
    init(viewModel: DocumentEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrided functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        controllerForNavigationItems?.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .more,
            style: .plain,
            target: self,
            action: #selector(showDocumentSettings)
        )
        
        windowHolder?.configureNavigationBarWithOpaqueBackground()
        
        insetsHelper = ScrollViewContentInsetsHelper(scrollView: collectionView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        insetsHelper = nil
        guard isMovingFromParent else { return }
    }
    
    private var controllerForNavigationItems: UIViewController? {
        guard parent is UINavigationController else {
            return parent
        }

        return self
    }
    
}

// MARK: - Initial Update data

extension DocumentEditorViewController {
    private func updateView() {
        UIView.performWithoutAnimation {
            dataSource.refresh(animatingDifferences: true)
        }
    }

    private func handleUpdateBlocks(blockIds: Set<BlockId>) {
        let sectionSnapshot = dataSource.snapshot(
            for: DocumentSection(
                icon: viewModel.documentIcon,
                cover: viewModel.documentCover
            )
        )
        var snapshot = dataSource.snapshot()
        var itemsForUpdate = sectionSnapshot.visibleItems.filter { blockIds.contains($0.blockId) }

        let focusedViewModelIndex = itemsForUpdate.firstIndex(where: { viewModel -> Bool in
            guard let indexPath = dataSource.indexPath(for: viewModel) else { return false }
            return collectionView.cellForItem(at: indexPath)?.isAnySubviewFirstResponder() ?? false
        })
        if let index = focusedViewModelIndex {
            updateFocusedViewModel(blockViewModel: itemsForUpdate.remove(at: index))
        }

        if itemsForUpdate.isEmpty {
            updateVisibleBlocks { content -> Bool in
                if case let .text(text) = content, text.contentType == .numbered {
                    return true
                }
                return false
            }
            return
        }
        snapshot.reloadItems(itemsForUpdate)
        apply(snapshot)
    }

    private func updateFocusedViewModel(blockViewModel: BaseBlockViewModel) {
        let needToUpdateView = gentlyReloadCell(for: blockViewModel)
        if needToUpdateView {
            updateView()
        }
        if let textViewModel = blockViewModel as? TextBlockViewModel,
           let focusAt = viewModel.document.userSession?.focusAt() {
            textViewModel.set(focus: focusAt)
        }
    }
        
    private func apply(_ snapshot: NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>,
                       animatingDifferences: Bool = true,
                       completion: (() -> Void)? = nil) {
        let selectedCells = collectionView.indexPathsForSelectedItems

        UIView.performWithoutAnimation {
            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
                self?.updateVisibleBlocks(satisfying: { (content) -> Bool in
                    if case let .text(text) = content,
                       [.toggle, .numbered].contains(text.contentType) {
                        return true
                    }
                    return false
                })
                completion?()

                selectedCells?.forEach {
                    self?.collectionView.selectItem(at: $0, animated: false, scrollPosition: [])
                }
            }
        }
    }
    
    private func applySnapshotAndSetFocus(_ snapshot: NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>,
                                          animatingDifferences: Bool = true) {
        apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
            self?.focusOnFocusedBlock()
        }
    }
    
    private func gentlyReloadCell(for blockViewModel: BaseBlockViewModel) -> Bool {
        guard let indexPath = dataSource.indexPath(for: blockViewModel) else { return false }
        guard let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return false }

        cell.indentationLevel = blockViewModel.indentationLevel()
        cell.contentConfiguration = blockViewModel.buildContentConfiguration()
        let prefferedSize = cell.systemLayoutSizeFitting(CGSize(width: cell.frame.size.width,
                                                                height: UIView.layoutFittingCompressedSize.height))
        return cell.frame.size.height != prefferedSize.height
    }

    // TODO: It should not be here. Move it to TextBlockViewModel
    private func updateVisibleBlocks(satisfying: (BlockContent) -> Bool) {
        var needToUpdateView = false

        let sectionSnapshot = dataSource.snapshot(
            for: DocumentSection(
                icon: viewModel.documentIcon,
                cover: viewModel.documentCover
            )
        )

        sectionSnapshot.visibleItems.forEach { item in
            guard satisfying(item.block.content) else { return }
            needToUpdateView = needToUpdateView || gentlyReloadCell(for: item)
        }
        if needToUpdateView {
            updateView()
        }
    }

    private func focusOnFocusedBlock() {
        let userSession = viewModel.document.userSession
        // TODO: we should move this logic to TextBlockViewModel
        if let id = userSession?.firstResponderId(), let focusedAt = userSession?.focusAt(),
           let blockViewModel = viewModel.blocksViewModels.first(where: { $0.blockId == id }) as? TextBlockViewModel {
                blockViewModel.set(focus: focusedAt)
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
        guard let viewModel = dataSource.itemIdentifier(for: indexPath) else { return false }
        if self.viewModel.selectionEnabled() {
            if case let .text(text) = viewModel.block.content {
                return text.contentType != .title
            }
            return true
        }
        switch viewModel.block.content {
        case .text:
            return false
        case let .file(file) where [.done, .uploading].contains(file.state):
            return false
        default:
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        guard let blockViewModel = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return blockViewModel.contextMenuInteraction()
    }
}

// MARK: TODO: Remove later.
extension DocumentEditorViewController {
    func getViewModel() -> DocumentEditorViewModel { self.viewModel }
}

// MARK: - EditorModuleDocumentViewInput

extension DocumentEditorViewController: PresentingViewController {
    
    func updateHeader() {
        var snapshot = NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>()
        snapshot.appendSections([
            DocumentSection(
                icon: viewModel.documentIcon,
                cover: viewModel.documentCover
            )
        ])
        
        snapshot.appendItems(dataSource.snapshot().itemIdentifiers)
        apply(snapshot)
    }
    
    func updateData(_ rows: [BaseBlockViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>()
        snapshot.appendSections([
            DocumentSection(
                icon: viewModel.documentIcon,
                cover: viewModel.documentCover
            )
        ])
        snapshot.appendItems(rows)
        // When we use apply data source without animation it's called reloadData under hood so it force to reload all cells.
        // We need it here cause items (BaseBlockViewModel) for collection is reference type.
        // The reason why we need it for ref type is follow - for reference type diffable data source compare items by pointer (address in memory).
        // So if item has changes, collection view will not see it cause pointer will be the same.
        // In future if we need animation we should use value type insted of reference as collection item.
        // Also we need restore focus due to reloadData сause dismissing keyboard.
        applySnapshotAndSetFocus(snapshot, animatingDifferences: false)
    }

    func showStyleMenu(blockModel: BlockModelProtocol, blockViewModel: BaseBlockViewModel) {
        guard let viewControllerForPresenting = parent else { return }
        self.view.endEditing(true)

        BottomSheetsFactory.createStyleBottomSheet(
            parentViewController: viewControllerForPresenting,
            delegate: self,
            blockModel: blockModel
        ) { [weak self] action in
            self?.viewModel.handleActionForFirstResponder(action)
        }

        if let indexPath = dataSource.indexPath(for: blockViewModel) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
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

}

extension DocumentEditorViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidRemove(_ fpc: FloatingPanelController) {
        let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first
        collectionView.deselectAllSelectedItems()

        let userSession = viewModel.document.userSession
        let blockModel = userSession?.firstResponder()

        guard let indexPath = selectedIndexPath,
              let blockViewModel = dataSource.itemIdentifier(for: indexPath),
              blockViewModel.blockId == blockModel?.information.id else { return }

        if let blockViewModel = blockViewModel as? TextBlockViewModel {
            let focus = userSession?.focusAt() ?? .end
            blockViewModel.set(focus: focus)
        }
    }
    
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        // Initialy keyboard is shown and we open context menu, so keyboard moves away
        // Then we select "Style" item from menu and display bottom sheet
        // Then system call "becomeFirstResponder" on UITextView which was firstResponder
        // and keyboard covers bottom sheet, this method helps us to unsure bottom sheet is visible
        if fpc.state == FloatingPanelState.full {
            view.endEditing(true)
        }
    }
}

// MARK: - Private extension

private extension DocumentEditorViewController {
    
    func setupUI() {
        setupCollectionView()
        setupInteractions()
    }

    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.pinAllEdges(to: view)
        
        collectionView.delegate = self
        collectionView.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }

    func makeCollectionViewDataSource() -> UICollectionViewDiffableDataSource<DocumentSection, BaseBlockViewModel> {
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
        <DocumentDetailsView>(elementKind: UICollectionView.elementKindSectionHeader) { detailsView, string, indexPath in
            guard
                let section = dataSource.snapshot().sectionIdentifiers[safe: indexPath.section]
            else {
                return
            }
            
            let detailsViewModel = DocumentDetailsViewModel(
                iconViewModel: section.icon.flatMap {
                    DocumentIconViewModel(icon: $0)
                },
                coverViewModel: section.cover.flatMap {
                    DocumentCoverViewModel(cover: $0)
                }
            )

            detailsView.configure(model: detailsViewModel)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] in
            return self?.collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryRegistration, for: $2)
        }
        
        return dataSource
    }

    func setupCell(cell: UICollectionViewListCell, indexPath: IndexPath, item: BaseBlockViewModel) {
        cell.contentConfiguration = item.buildContentConfiguration()
        cell.indentationWidth = Constants.cellIndentationWidth
        cell.indentationLevel = item.indentationLevel()
        cell.contentView.isUserInteractionEnabled = !self.viewModel.selectionEnabled()

        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
    }

    func setupInteractions() {
        self.configured()
        
        listViewTapGestureRecognizer.addTarget(self, action: #selector(tapOnListViewGestureRecognizerHandler))
        self.view.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }

    @objc func tapOnListViewGestureRecognizerHandler() {
        guard viewModel.selectionEnabled() == false else {
            return
        }
        
        let location = self.listViewTapGestureRecognizer.location(in: collectionView)
        
        if location.y > (collectionView.visibleCells.last?.frame.maxY ?? 0) {
            viewModel.handlingTapOnEmptySpot()
        }
    }

    /// Add handlers to viewModel state changes
    func configured() {
        viewModel.updateElementsPublisher.sink { [weak self] value in
            self?.handleUpdateBlocks(blockIds: value)
        }.store(in: &self.subscriptions)

        viewModel.selectionHandler.selectionEventPublisher().sink(receiveValue: { [weak self] value in
            self?.handleSelection(event: value)
        }).store(in: &self.subscriptions)
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
   
    @objc
    func showDocumentSettings() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        present(
            viewModel.settingViewModel.makeSettingsViewController(),
            animated: false
        )
    }
    
}

// MARK: - Constants

private extension DocumentEditorViewController {
    
    enum Constants {
        static let cellIndentationWidth: CGFloat = 24
    }
    
}
