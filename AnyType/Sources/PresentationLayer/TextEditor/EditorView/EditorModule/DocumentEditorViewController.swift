import BlocksModels
import UIKit
import Combine
import FloatingPanel


final class DocumentEditorViewController: UICollectionViewController {

    private enum Constants {
        static let headerReuseId = "header"
        static let cellIndentationWidth: CGFloat = 24
        static let cellReuseId: String = NSStringFromClass(UICollectionViewListCell.self)
    }

    private var dataSource: UICollectionViewDiffableDataSource<DocumentSection, BaseBlockViewModel>?
    private let viewModel: DocumentEditorViewModel
    private let viewCellFactory: DocumentViewCellFactoryProtocol

    private var subscriptions: Set<AnyCancellable> = []
    /// Gesture recognizer to handle taps in empty document
    private let listViewTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer: UITapGestureRecognizer = .init()
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()

    init(viewModel: DocumentEditorViewModel, viewCellFactory: DocumentViewCellFactoryProtocol) {
        self.viewModel = viewModel
        self.viewCellFactory = viewCellFactory
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.headerMode = .supplementary
        listConfiguration.backgroundColor = .white
        listConfiguration.showsSeparators = false
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: listConfiguration))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isMovingFromParent else { return }
        self.viewModel.applyPendingChanges()
    }

    private func setupUI() {
        setupCollectionViewDataSource()
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .systemBackground
        collectionView.addGestureRecognizer(self.listViewTapGestureRecognizer)
        
        setupInteractions()
    }


    private func setupCollectionViewDataSource() {
        collectionView.register(
            DocumentDetailsView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Constants.headerReuseId
        )

        collectionView.register(
            UICollectionViewListCell.self,
            forCellWithReuseIdentifier: Constants.cellReuseId
        )

        self.dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] (view, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return UICollectionViewListCell() }
            
            let cell = view.dequeueReusableCell(
                withReuseIdentifier: Constants.cellReuseId,
                for: indexPath
            ) as? UICollectionViewListCell
            
            cell?.contentConfiguration = item.buildContentConfiguration()
            cell?.indentationWidth = Constants.cellIndentationWidth
            cell?.indentationLevel = item.indentationLevel()
            
            if cell?.selectedBackgroundView == nil {
                cell?.selectedBackgroundView = self.viewCellFactory.makeSelectedBackgroundViewForBlockCell()
            }
            
            cell?.contentView.isUserInteractionEnabled = !self.viewModel.selectionEnabled()
            
            return cell
        }

        self.dataSource?.supplementaryViewProvider = { [weak self] view, type, indexPath in
            guard
                let headerView = view.dequeueReusableSupplementaryView(
                    ofKind: type,
                    withReuseIdentifier: Constants.headerReuseId,
                    for: indexPath
                ) as? DocumentDetailsView
            else {
                assertionFailure("Unable to create proper header view")
                return UICollectionReusableView()
            }
                        
            guard let viewModel = self?.viewModel.detailsViewModel else { return headerView }
            
            headerView.configure(model: viewModel)
            
            return headerView
        }
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
        self.viewModel.publicSizeDidChangePublisher.reciveOnMain().sink { [weak self] (value) in
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
        textModel?.set(focus: BlockTextViewModel.Focus(position: focusPosition,
                                                                     completion: { _ in }))
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
        guard
            collectionView.numberOfSections > 0,
            let dataSource = dataSource
        else { return }
        
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.first])
        
        apply(snapshot)
    }
        
    private func deselectAllBlocks() {
        self.collectionView.deselectAllSelectedItems()
        self.collectionView.visibleCells.forEach { $0.contentView.isUserInteractionEnabled = true }
    }

    private func toggleBlockViewModelsForUpdate() -> [BaseBlockViewModel] {
        return self.collectionView.indexPathsForVisibleItems.compactMap { indexPath -> BaseBlockViewModel? in
            guard let builder = self.viewModel.builders[safe: indexPath.row] else { return nil }
            let content = builder.getBlock().blockModel.information.content
            guard case let .text(text) = content, text.contentType == .toggle else {
                return nil
            }
            guard let configuration = self.collectionView.cellForItem(at: indexPath)?.contentConfiguration as? ToggleBlockContentConfiguration,
                  configuration.hasChildren == builder.getBlock().childrenIds().isEmpty else {
                return nil
            }
            return builder
        }
    }
}

// MARK: - HeaderView PageDetails

extension DocumentEditorViewController {
    
    private func scrollAndFocusOnFocusedBlock() {
        guard let dataSource = self.dataSource else { return }
        let snapshot = dataSource.snapshot(for: .first)
        let userSession = self.viewModel.documentViewModel.userSession
        if let id = userSession?.firstResponderId(), let focusedAt = userSession?.focusAt() {
            let itemIdentifiers = snapshot.visibleItems
            if let index = itemIdentifiers.firstIndex(where: { (value) -> Bool in
                value.blockId == id
            }) {
                (itemIdentifiers[index] as? TextBlockViewModel)?.set(focus: .init(position: focusedAt, completion: {_ in }))
                userSession?.unsetFocusAt()
                userSession?.unsetFirstResponder()
            }
        }
    }
}

// MARK: - Initial Update data
extension DocumentEditorViewController {
    private func updateView() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
        
    private func apply(_ snapshot: NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>) {
        UIView.performWithoutAnimation {
            self.dataSource?.apply(snapshot, animatingDifferences: true) { [weak self] in
                self?.updateVisibleNumberedItems()
                self?.scrollAndFocusOnFocusedBlock()
            }
        }
    }
    
    private func updateVisibleNumberedItems() {
        self.collectionView.indexPathsForVisibleItems.forEach {
            guard let builder = self.viewModel.builders[safe: $0.row] else { return }
            let content = builder.getBlock().blockModel.information.content
            guard case let .text(text) = content, text.contentType == .numbered else { return }
            self.collectionView.cellForItem(at: $0)?.contentConfiguration = builder.buildContentConfiguration()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension DocumentEditorViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didSelectBlock(at: indexPath)
        if self.viewModel.selectionEnabled() {
            return
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if !self.viewModel.selectionEnabled() {
            return
        }
        self.viewModel.didSelectBlock(at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let viewModel = self.dataSource?.itemIdentifier(for: indexPath) else { return false }
        if self.viewModel.selectionEnabled() {
            if case let .text(text) = viewModel.getBlock().blockModel.information.content {
                return text.contentType != .title
            }
            return true
        }
        switch viewModel.getBlock().blockModel.information.content {
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
            let userSession = self.viewModel.documentViewModel.userSession
            textItem.set(focus: .init(position: userSession?.focusAt() ?? .end, completion: {_ in }))
        }
    }
    
    func updateData(_ rows: [BaseBlockViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<DocumentSection, BaseBlockViewModel>()
        snapshot.appendSections([.first])
        snapshot.appendItems(rows)
        snapshot.reloadItems(self.toggleBlockViewModelsForUpdate())
        self.apply(snapshot)
    }
    
    func delete(rows: [BaseBlockViewModel]) {
        guard var snapshot = self.dataSource?.snapshot() else { return }
        snapshot.deleteItems(rows)
        snapshot.reloadItems(self.toggleBlockViewModelsForUpdate())
        self.apply(snapshot)
    }
    
    func insert(rows: [BaseBlockViewModel], after row: BaseBlockViewModel) {
        guard var snapshot = self.dataSource?.snapshot() else { return }
        snapshot.insertItems(rows, afterItem: row)
        self.apply(snapshot)
    }

    func showCodeLanguageView(with languages: [String], completion: @escaping (String) -> Void) {
        let searchListViewController = SearchListViewController(items: languages, completion: completion)
        modalPresentationStyle = .pageSheet
        present(searchListViewController, animated: true)
    }

    func showStyleMenu(blockModel: BlockModelProtocol) {
        guard let viewControllerForPresenting = parent else { return }

        self.view.endEditing(true)

        let fpc = FloatingPanelController()
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16.0
        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.grayscale90
        shadow.offset = CGSize(width: 0, height: 4)
        shadow.radius = 40
        shadow.opacity = 0.25
        appearance.shadows = [shadow]

        fpc.surfaceView.layer.cornerCurve = .continuous

        fpc.surfaceView.containerMargins = .init(top: 0, left: 10.0, bottom: view.safeAreaInsets.bottom + 6, right: 10.0)
        fpc.surfaceView.grabberHandleSize = .init(width: 48.0, height: 4.0)
        fpc.surfaceView.grabberHandle.barColor = .grayscale30
        fpc.surfaceView.appearance = appearance
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.layout = StylePanelLayout()
        fpc.backdropView.backgroundColor = .clear
        fpc.contentMode = .static

        // NOTE: This will be moved to coordinator in next pr
        guard case let .text(textContentType) = blockModel.information.content.type else { return }
        let askAttributes: () -> TextAttributesViewController.AttributesState = {
            guard case let .text(textContent) = blockModel.information.content else {
                return .init(hasBold: false, hasItalic: false, hasStrikethrough: false, hasCodeStyle: false)
            }

            let range = NSRange(location: 0, length: textContent.attributedText.length)

            let hasBold = textContent.attributedText.hasTrait(trait: .traitBold, at: range)
            let hasItalic = textContent.attributedText.hasTrait(trait: .traitItalic, at: range)
            let hasStrikethrough = textContent.attributedText.hasAttribute(.strikethroughStyle, at: range)
            let alignment = BlocksModelsParserCommonAlignmentUIKitConverter.asUIKitModel(blockModel.information.alignment) ?? .left

            let attributes = TextAttributesViewController.AttributesState(
                hasBold: hasBold, hasItalic: hasItalic, hasStrikethrough: hasStrikethrough, hasCodeStyle: false, alignment: alignment, url: ""
            )
            return attributes
        }

        typealias ColorConverter = MiddlewareModelsModule.Parsers.Text.Color.Converter
        let askColor: () -> UIColor? = {
            guard case let .text(textContent) = blockModel.information.content else { return nil }
            return ColorConverter.asModel(textContent.color, background: false)
        }
        let askBackgroundColor: () -> UIColor? = {
            return ColorConverter.asModel(blockModel.information.backgroundColor, background: true)
        }

        let contentVC = StyleViewController(viewControllerForPresenting: viewControllerForPresenting,
                                            style: textContentType,
                                            askColor: askColor,
                                            askBackgroundColor: askBackgroundColor,
                                            askTextAttributes: askAttributes
                                            ) { [weak self] action in
            self?.viewModel.handleAction(action)
        }
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: viewControllerForPresenting, animated: true)
    }
}
