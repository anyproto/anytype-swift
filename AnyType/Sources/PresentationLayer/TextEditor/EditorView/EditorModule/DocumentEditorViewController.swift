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
    private weak var headerViewModel: DocumentEditorHeaderView.ViewModel?
    private(set) lazy var headerViewModelPublisher: AnyPublisher<DocumentEditorHeaderView.UserAction, Never>? = self.headerViewModel?.$userAction.safelyUnwrapOptionals().eraseToAnyPublisher()

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
        self.updateData(self.viewModel.builders)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isMovingFromParent else { return }
        self.viewModel.applyPendingChanges()
    }

    private func setupUI() {
        self.setupCollectionViewDataSource()
        self.collectionView?.allowsMultipleSelection = true
        self.collectionView?.backgroundColor = .systemBackground
        self.collectionView?.addGestureRecognizer(self.listViewTapGestureRecognizer)
        self.setupInteractions()
        self.setupHeaderPageDetailsEvents()
    }


    private func setupCollectionViewDataSource() {
        guard let listView = self.collectionView else { return }

        listView.register(DocumentEditorHeaderView.self,
                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                          withReuseIdentifier: Constants.headerReuseId)

        listView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: Constants.cellReuseId)

        self.dataSource = UICollectionViewDiffableDataSource(collectionView: listView) { [weak self] (view, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return UICollectionViewListCell() }
            let cell = view.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseId,
                                                for: indexPath) as? UICollectionViewListCell
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
            guard let headerView = view.dequeueReusableSupplementaryView(ofKind: type,
                                                                         withReuseIdentifier: Constants.headerReuseId,
                                                                         for: indexPath) as? DocumentEditorHeaderView else {
                assertionFailure("Unable to create proper header view")
                return UICollectionReusableView()
            }
            if headerView.headerView.viewModel == nil {
                headerView.headerView.viewModel = .init()
                self?.headerViewModel = headerView.headerView.viewModel
            }
            return headerView
        }
    }

    private func setupInteractions() {
        self.configured()

        self.viewModel.$options.sink(receiveValue: { [weak self] (options) in
            self?.configured(options)
        }).store(in: &self.subscriptions)
    }

    @objc private func tapOnListViewGestureRecognizerHandler() {
        if self.viewModel.selectionEnabled() {
            return
        }
        let location = self.listViewTapGestureRecognizer.location(in: self.listViewTapGestureRecognizer.view)
        if self.collectionView.visibleCells.first(where: {$0.frame.contains(location)}) != nil {
            return
        }
        self.viewModel.handlingTapIfEmpty()
    }

    /// Add handlers to viewModel state changes
    private func configured() {
        self.viewModel.publicSizeDidChangePublisher.receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.updateView()
        }.store(in: &self.subscriptions)

        self.viewModel.updateElementsPublisher.sink { [weak self] (value) in
            guard let sectionSnapshot = self?.dataSource?.snapshot(for: .first),
                  var snapshot = self?.dataSource?.snapshot() else { return }
            let set: Set = .init(value)
            let itemsForUpdate = sectionSnapshot.visibleItems.filter { set.contains($0.blockId) }
            if itemsForUpdate.isEmpty {
                return
            }
            snapshot.reloadItems(itemsForUpdate)
            self?.apply(snapshot)
        }.store(in: &self.subscriptions)

        self.viewModel.selectionHandler?.selectionEventPublisher().sink(receiveValue: { [weak self] value in
            guard let self = self else { return }
            switch value {
            case .selectionDisabled:
                self.deselectAllBlocks()
            case let .selectionEnabled(event):
                switch event {
                case .isEmpty:
                    self.deselectAllBlocks()
                case let .nonEmpty(count, _):
                    // We always count with this "1" because of top title block, which is not selectable
                    if count == self.collectionView.numberOfItems(inSection: 0) - 1 {
                        self.collectionView.selectAllItems(startingFrom: 1)
                    }
                }
                self.collectionView.visibleCells.forEach { $0.contentView.isUserInteractionEnabled = false }
            }
        }).store(in: &self.subscriptions)
    }

    private func deselectAllBlocks() {
        self.collectionView.deselectAllSelectedItems()
        self.collectionView.visibleCells.forEach { $0.contentView.isUserInteractionEnabled = true }
    }

    /// Method called when viewmodel options updated
    ///
    /// - Parameters:
    ///   - options: Options
    private func configured(_ options: DocumentEditorViewModel.Options) {
        if options.shouldCreateEmptyBlockOnTapIfListIsEmpty {
            self.listViewTapGestureRecognizer.addTarget(self, action: #selector(tapOnListViewGestureRecognizerHandler))
            self.view.addGestureRecognizer(self.listViewTapGestureRecognizer)
        }
        else {
            self.listViewTapGestureRecognizer.removeTarget(self, action: #selector(tapOnListViewGestureRecognizerHandler))
            self.view.removeGestureRecognizer(self.listViewTapGestureRecognizer)
        }
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
    private func process(event: DocumentEditorViewModel.UserEvent) {
        switch event {
        case .pageDetailsViewModelsDidSet:
            let viewModels = self.viewModel.detailsViewModels.filter({[.iconEmoji, .title].contains($0.key)})
                .map({$0})
                .reordered(by: [.iconEmoji, .title], findInCollection: { (value, collection) in
                    collection.firstIndex(of: value.key)
                })
                .compactMap({$0.value})
            _ = self.headerViewModel?.configured(pageDetailsViewModels: viewModels)
        }
    }
    
    private func setupHeaderPageDetailsEvents() {
        self.viewModel.$userEvent.safelyUnwrapOptionals().sink { [weak self] (value) in
            self?.process(event: value)
        }.store(in: &self.subscriptions)
    }
    
    private func scrollAndFocusOnFocusedBlock() {
        guard let dataSource = self.dataSource else { return }
        let snapshot = dataSource.snapshot(for: .first)
        let userSession = self.viewModel.documentViewModel.userSession
        if let id = userSession?.firstResponder(), let focusedAt = userSession?.focusAt() {
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
        self.collectionView?.collectionViewLayout.invalidateLayout()
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

    func showStyleMenu() {
        self.view.endEditing(true)

        let fpc = FloatingPanelController()
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16.0
        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 4)
        shadow.radius = 40
        shadow.opacity = 0.25
        appearance.shadows = [shadow]

        fpc.surfaceView.layer.cornerCurve = .continuous

        fpc.surfaceView.containerMargins = .init(top: 0, left: 10.0, bottom: view.safeAreaInsets.bottom + 6, right: 10.0)
        fpc.surfaceView.grabberHandleSize = .init(width: 48.0, height: 4.0)
        fpc.surfaceView.grabberHandle.barColor = .stroke
        fpc.surfaceView.appearance = appearance
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.layout = StylePanelLayout()
        fpc.backdropView.backgroundColor = .clear
        fpc.contentMode = .static

        let contentVC = StyleViewController()
        fpc.set(contentViewController: contentVC)

        guard let vc = parent else { return }

        fpc.addPanel(toParent: vc, animated: true)
    }
}
