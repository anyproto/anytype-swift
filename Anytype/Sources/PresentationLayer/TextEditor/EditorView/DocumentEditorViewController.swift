import BlocksModels
import UIKit
import Combine
import FloatingPanel
import SwiftUI
import Amplitude


final class DocumentEditorViewController: UIViewController {
    
    private lazy var dataSource = makeCollectionViewDataSource()
    
    private let collectionView: UICollectionView = {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
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
    private var firstResponderHelper: FirstResponderHelper?
    private var contentOffset: CGPoint = .zero
    
    private var selectionSubscription: AnyCancellable?
    // Gesture recognizer to handle taps in empty document
    private let listViewTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer: UITapGestureRecognizer = .init()
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()

    var viewModel: DocumentEditorViewModel!

    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrided functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.viewLoaded()
        setupUI()
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
        firstResponderHelper = FirstResponderHelper(scrollView: collectionView)
        insetsHelper = ScrollViewContentInsetsHelper(scrollView: collectionView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        insetsHelper = nil
        firstResponderHelper = nil
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
        
    private func apply(
        _ snapshot: NSDiffableDataSourceSnapshot<ObjectSection, DataSourceItem>,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let selectedCells = collectionView.indexPathsForSelectedItems

        UIView.performWithoutAnimation {
            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
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

// MARK: - UICollectionViewDelegate
extension DocumentEditorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectBlock(at: indexPath)
        if viewModel.selectionHandler.selectionEnabled {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if !viewModel.selectionHandler.selectionEnabled {
            return
        }
        self.viewModel.didSelectBlock(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        if viewModel.selectionHandler.selectionEnabled {
            switch item {
            case let .block(block):
                guard case let .text(text) = block.content else { return true }
                return text.contentType != .title
            }
        }
        
        switch item {
        case let .block(block):
            guard case .text = block.content else { return true }
            return false
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }

        switch item {
        case let .block(block):
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.popupActionMenu)
            
            return block.contextMenuConfiguration()
        }
    }
}

// MARK: - EditorModuleDocumentViewInput

extension DocumentEditorViewController: EditorModuleDocumentViewInput {
    func updateRowsWithoutRefreshing(ids: Set<BlockId>) {
        let sectionSnapshot = dataSource.snapshot(for: .main)
        
        sectionSnapshot.visibleItems.forEach { item in
            switch item {
            case let .block(block):
                guard
                    ids.contains(block.information.id),
                    let indexPath = dataSource.indexPath(for: item),
                    let cell = collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell
                else { return }
                
                cell.contentConfiguration = block.makeContentConfiguration(maxWidth: cell.bounds.width)
            }
        }
        updateView()
    }
    
    func updateData(_ blocksViewModels: [BlockViewModelProtocol]) {
        var snapshot = NSDiffableDataSourceSnapshot<ObjectSection, DataSourceItem>()
        snapshot.appendSections([.main])

        let items = blocksViewModels.map { DataSourceItem.block($0) }
        snapshot.appendItems(items)

        apply(snapshot) { [weak self] in
            guard let self = self else { return }

            let sectionSnapshot = self.dataSource.snapshot(for: .main)
            
            sectionSnapshot.visibleItems.forEach { item in
                switch item {
                case let .block(block):
                    guard let indexPath = self.dataSource.indexPath(for: item) else { return }
                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? UICollectionViewListCell else { return }
                    
                    cell.contentConfiguration = block.makeContentConfiguration(maxWidth: cell.bounds.width)
                    cell.indentationLevel = block.indentationLevel
                }
            }

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

}

// MARK: - FloatingPanelControllerDelegate

extension DocumentEditorViewController: FloatingPanelControllerDelegate {
    
    func floatingPanelDidRemove(_ fpc: FloatingPanelController) {
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.collectionView.contentInset.bottom = 0
        }

        guard
            let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first
        else { return }
        
        collectionView.deselectAllSelectedItems()

        let userSession = viewModel.document.userSession
        let blockModel = userSession?.firstResponder

        guard
            let item = dataSource.itemIdentifier(for: selectedIndexPath)
        else { return }
        
        switch item {
        case let .block(block):
            guard block.information.id == blockModel?.information.id else { return }
            
            if let blockViewModel = block as? TextBlockViewModel {
                let focus = userSession?.focus ?? .end
                blockViewModel.set(focus: focus)
            }
            
        }
        
    }

    func adjustContentOffset(fpc: FloatingPanelController) {
        let selectedItems = collectionView.indexPathsForSelectedItems ?? []

        // find first visible blocks
        let closestItem = selectedItems.first { indexPath in
            collectionView.indexPathsForVisibleItems.contains(indexPath)
        }

        // if visible block was found
        if let closestItem = closestItem {
            guard let itemCell = collectionView.cellForItem(at: closestItem) else { return }
            let itemPointInCollection = itemCell.convert(itemCell.bounds, to: view)

            // if visible block not intersect style menu than do nothing
            if !itemPointInCollection.intersects(fpc.surfaceView.frame) {
                collectionView.contentInset.bottom = fpc.surfaceView.bounds.height
                return
            }
        }
        // if visible block intersect style menu or block is not visible than calculate collectionView contentOffset
        guard let closestItem = closestItem == nil ? selectedItems.first : closestItem else { return }
        guard let closestItemAttributes = collectionView.layoutAttributesForItem(at: closestItem)  else { return }

        let yOffset = closestItemAttributes.frame.maxY - collectionView.bounds.height + fpc.surfaceView.bounds.height + fpc.surfaceView.layoutMargins.bottom
        collectionView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
        collectionView.contentInset.bottom = fpc.surfaceView.bounds.height
    }

    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        let surfaceOffset = fpc.surfaceLocation.y - fpc.surfaceLocation(for: .full).y
        // If panel moved more than a half of its hight than hide panel
        if fpc.surfaceView.bounds.height / 2 < surfaceOffset {
            return true
        }
        return false
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
    
    func makeCollectionViewDataSource() -> UICollectionViewDiffableDataSource<ObjectSection, DataSourceItem> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, BlockViewModelProtocol> { [weak self] (cell, indexPath, item) in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }

        let codeCellRegistration = UICollectionView.CellRegistration<CodeBlockCellView, BlockViewModelProtocol> { [weak self] (cell, indexPath, item) in
            self?.setupCell(cell: cell, indexPath: indexPath, item: item)
        }

        let dataSource = UICollectionViewDiffableDataSource<ObjectSection, DataSourceItem>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: DataSourceItem) -> UICollectionViewCell? in

            switch item {
            case let .block(block):
                guard case .text(.code) = block.content.type else {
                    return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: block)
                }
                
                return collectionView.dequeueConfiguredReusableCell(using: codeCellRegistration, for: indexPath, item: block)
            }
        }
        
        return dataSource
    }

    func setupCell(cell: UICollectionViewListCell, indexPath: IndexPath, item: BlockViewModelProtocol) {
        cell.contentConfiguration = item.makeContentConfiguration(maxWidth: cell.bounds.width)
        cell.indentationWidth = Constants.cellIndentationWidth
        cell.indentationLevel = item.indentationLevel
        cell.contentView.isUserInteractionEnabled = !viewModel.selectionHandler.selectionEnabled

        cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
    }

    func setupInteractions() {
        selectionSubscription = viewModel.selectionHandler.selectionEventPublisher().sink { [weak self] value in
            self?.handleSelection(event: value)
        }
        
        listViewTapGestureRecognizer.addTarget(self, action: #selector(tapOnListViewGestureRecognizerHandler))
        self.view.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }

    @objc func tapOnListViewGestureRecognizerHandler() {
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
   
    @objc
    func showDocumentSettings() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        // TODO: move to assembly
        let controller = UIHostingController(
            rootView: ObjectSettingsContainerView(viewModel: viewModel.objectSettingsViewModel)
        )
        controller.modalPresentationStyle = .overCurrentContext
        
        controller.view.backgroundColor = .clear
        controller.view.isOpaque = false
        
        controller.rootView.onHide = { [weak controller] in
            controller?.dismiss(animated: false)
        }
        
        present(
            controller,
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
