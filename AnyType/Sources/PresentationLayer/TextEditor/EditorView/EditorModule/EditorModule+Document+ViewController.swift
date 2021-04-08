//
//  DocumentViewController+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import Combine

fileprivate typealias Namespace = EditorModule.Document

extension Namespace {
    final class ViewController: UICollectionViewController {
        
        private enum Constants {
            static let headerReuseId = "header"
            static let cellIndentationWidth: CGFloat = 24
            static let cellReuseId: String = UICollectionViewListCell.cellReuseIdentifier()
        }
        
        private var dataSource: UICollectionViewDiffableDataSource<DocumentSection, BlocksViews.Base.ViewModel>?
        private let viewModel: ViewModel
        private weak var headerViewModel: HeaderView.ViewModel?
        private(set) lazy var headerViewModelPublisher: AnyPublisher<HeaderView.UserAction, Never>? = self.headerViewModel?.$userAction.safelyUnwrapOptionals().eraseToAnyPublisher()
                
        private var subscriptions: Set<AnyCancellable> = []
        /// Gesture recognizer to handle taps in empty document
        private let listViewTapGestureRecognizer: UITapGestureRecognizer = {
            let recognizer: UITapGestureRecognizer = .init()
            recognizer.cancelsTouchesInView = false
            return recognizer
        }()

        init(viewModel: ViewModel) {
            self.viewModel = viewModel
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
            self.collectionView?.backgroundColor = .systemBackground
            self.collectionView?.addGestureRecognizer(self.listViewTapGestureRecognizer)
            self.setupInteractions()
            self.setupHeaderPageDetailsEvents()
        }
        
        
        private func setupCollectionViewDataSource() {
            guard let listView = self.collectionView else { return }
            
            listView.register(CollectionViewHeaderView.self,
                              forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                              withReuseIdentifier: Constants.headerReuseId)
            
            listView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: Constants.cellReuseId)
            
            self.dataSource = UICollectionViewDiffableDataSource(collectionView: listView) { (view, indexPath, item) -> UICollectionViewCell? in
                let cell = view.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseId,
                                                    for: indexPath) as? UICollectionViewListCell
                cell?.contentConfiguration = item.buildContentConfiguration()
                cell?.indentationWidth = Constants.cellIndentationWidth
                cell?.indentationLevel = item.indentationLevel()

                return cell
            }

            self.dataSource?.supplementaryViewProvider = { [weak self] view, type, indexPath in
                guard let headerView = view.dequeueReusableSupplementaryView(ofKind: type,
                                                                             withReuseIdentifier: Constants.headerReuseId,
                                                                             for: indexPath) as? CollectionViewHeaderView else {
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
        }

        /// Method called when viewmodel options updated
        ///
        /// - Parameters:
        ///   - options: Options
        private func configured(_ options: ViewModel.Options) {
            if options.shouldCreateEmptyBlockOnTapIfListIsEmpty {
                self.listViewTapGestureRecognizer.addTarget(self, action: #selector(tapOnListViewGestureRecognizerHandler))
                self.view.addGestureRecognizer(self.listViewTapGestureRecognizer)
            }
            else {
                self.listViewTapGestureRecognizer.removeTarget(self, action: #selector(tapOnListViewGestureRecognizerHandler))
                self.view.removeGestureRecognizer(self.listViewTapGestureRecognizer)
            }
        }
        
        private func toggleBlockViewModelsForUpdate() -> [BlocksViews.Base.ViewModel] {
            return self.collectionView.indexPathsForVisibleItems.compactMap { indexPath -> BlocksViews.Base.ViewModel? in
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
}

// MARK: - HeaderView PageDetails
extension Namespace.ViewController {
    private func process(event: ViewModel.UserEvent) {
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
        let userSession = self.viewModel.documentViewModel.getUserSession()
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
extension Namespace.ViewController {
    private func updateView() {
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }
        
    private func apply(_ snapshot: NSDiffableDataSourceSnapshot<DocumentSection, BlocksViews.Base.ViewModel>) {
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
extension Namespace.ViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didSelectBlock(at: indexPath)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let viewModel = self.dataSource?.itemIdentifier(for: indexPath) else { return false }
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
extension Namespace.ViewController {
    func getViewModel() -> ViewModel { self.viewModel }
}

// MARK: - EditorModuleDocumentViewInput

extension Namespace.ViewController: EditorModuleDocumentViewInput {
    func setFocus(at index: Int) {
        guard !self.viewModel.selectionEnabled() else { return }
        guard let snapshot = self.dataSource?.snapshot() else { return }
        let itemIdentifiers = snapshot.itemIdentifiers(inSection: .first)
        if let textItem = itemIdentifiers[index] as? TextBlockViewModel {
            let userSession = self.viewModel.documentViewModel.getUserSession()
            textItem.set(focus: .init(position: userSession?.focusAt() ?? .end, completion: {_ in }))
        }
    }
    
    func updateData(_ rows: [BlocksViews.Base.ViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<DocumentSection, BlocksViews.Base.ViewModel>()
        snapshot.appendSections([.first])
        snapshot.appendItems(rows)
        snapshot.reloadItems(self.toggleBlockViewModelsForUpdate())
        self.apply(snapshot)
    }
    
    func delete(rows: [BlocksViews.Base.ViewModel]) {
        guard var snapshot = self.dataSource?.snapshot() else { return }
        snapshot.deleteItems(rows)
        snapshot.reloadItems(self.toggleBlockViewModelsForUpdate())
        self.apply(snapshot)
    }
    
    func insert(rows: [BlocksViews.Base.ViewModel], after row: BlocksViews.Base.ViewModel) {
        guard var snapshot = self.dataSource?.snapshot() else { return }
        snapshot.insertItems(rows, afterItem: row)
        self.apply(snapshot)
    }

}
