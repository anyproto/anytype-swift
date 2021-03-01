//
//  DocumentViewController+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

fileprivate typealias Namespace = EditorModule.Document

/// Input data for document view
protocol EditorModuleDocumentViewInput: AnyObject {
    /// Set focus
    /// - Parameter index: Block index
    func setFocus(at index: Int)
}

extension Namespace {
    final class ViewController: UICollectionViewController {
        
        private enum Constants {
            static let headerReuseId = "header"
        }
        
        @Environment(\.developerOptions) private var developerOptions
        private var dataSource: UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Row>?
        private let viewModel: ViewModel
        private let headerViewModel: HeaderView.ViewModel = .init()
        private(set) lazy var headerViewModelPublisher: AnyPublisher<HeaderView.UserAction, Never> = self.headerViewModel.$userAction.safelyUnwrapOptionals().eraseToAnyPublisher()
                
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
            // TODO: Redone on top of Combine.
            // We should fire event, when somebody is subscribed buildersRows.
            self.updateData(self.viewModel.buildersRows)
        }
        
        private func setupUI() {
            self.setupCollectionView()
            self.setupCollectionViewDataSource()
            self.collectionView?.addGestureRecognizer(self.listViewTapGestureRecognizer)
            self.setupInteractions()
            self.setupHeaderPageDetailsEvents()
        }
        
        private func setupCollectionView() {
            self.collectionView.register(CollectionViewHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.headerReuseId)
            self.collectionView?.register(EditorModule.Document.Cells.CollectionViewCell.self, forCellWithReuseIdentifier: EditorModule.Document.Cells.CollectionViewCell.cellReuseIdentifier())
        }
        
        private func setupCollectionViewDataSource() {
            guard let listView = self.collectionView else { return }
            
            listView.register(Cells.ContentConfigurations.Text.Text.Collection.self, forCellWithReuseIdentifier: Cells.ContentConfigurations.Text.Text.Collection.cellReuseIdentifier())
            
            listView.register(Cells.ContentConfigurations.Text.Quote.Collection.self, forCellWithReuseIdentifier: EditorModule.Document.Cells.ContentConfigurations.Text.Quote.Collection.cellReuseIdentifier())
            
            listView.register(Cells.ContentConfigurations.File.File.Collection.self, forCellWithReuseIdentifier: Cells.ContentConfigurations.File.File.Collection.cellReuseIdentifier())
            
            listView.register(Cells.ContentConfigurations.File.Image.Collection.self, forCellWithReuseIdentifier: Cells.ContentConfigurations.File.Image.Collection.cellReuseIdentifier())
            
            listView.register(Cells.ContentConfigurations.Bookmark.Bookmark.Collection.self, forCellWithReuseIdentifier: Cells.ContentConfigurations.Bookmark.Bookmark.Collection.cellReuseIdentifier())
            
            listView.register(Cells.ContentConfigurations.Other.Divider.Collection.self, forCellWithReuseIdentifier: Cells.ContentConfigurations.Other.Divider.Collection.cellReuseIdentifier())
            
            listView.register(Cells.ContentConfigurations.Link.PageLink.Collection.self, forCellWithReuseIdentifier: Cells.ContentConfigurations.Link.PageLink.Collection.cellReuseIdentifier())

            listView.register(Cells.ContentConfigurations.Unknown.Label.Collection.self, forCellWithReuseIdentifier: Cells.ContentConfigurations.Unknown.Label.Collection.cellReuseIdentifier())

            
            self.dataSource = UICollectionViewDiffableDataSource(collectionView: listView) { (view, indexPath, item) -> UICollectionViewCell? in
                guard let ourBuilder = item.builder as? BlocksViews.New.Base.ViewModel else {
                    assertionFailure("Check builder")
                    return nil
                }
                let cellId = EditorModuleCellIdentifierConverter.identifier(for: ourBuilder)
                let cell = view.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
                
                let configuration = ourBuilder.buildContentConfiguration()
                cell.contentConfiguration = configuration
                return cell
            }

            self.dataSource?.supplementaryViewProvider = { view, type, indexPath in
                guard let headerView = view.dequeueReusableSupplementaryView(ofKind: type,
                                                                             withReuseIdentifier: Constants.headerReuseId,
                                                                             for: indexPath) as? CollectionViewHeaderView else {
                    assertionFailure("Unable to create proper header view")
                    return UICollectionReusableView()
                }
                if headerView.headerView.viewModel == nil {
                    headerView.headerView.viewModel = self.headerViewModel
                }
                return headerView
            }
            self.collectionView.dataSource = self.dataSource
        }

        private func setupInteractions() {
            self.configured()
            
            self.viewModel.$options.sink(receiveValue: { [weak self] (options) in
                self?.configured(options)
            }).store(in: &self.subscriptions)
        }
        
        @objc private func tapOnListViewGestureRecognizerHandler() {
            self.viewModel.handlingTapIfEmpty()
        }
        
        /// Add handlers to viewmdoel state changes
        private func configured() {
            self.viewModel.$buildersRows.sink(receiveValue: { [weak self] (value) in
                self?.updateData(value)
            }).store(in: &self.subscriptions)

            self.viewModel.publicSizeDidChangePublisher.receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.updateView()
            }.store(in: &self.subscriptions)

            self.viewModel.anyStylePublisher.sink { [weak self] (value) in
                guard let self = self else { return }
                self.updateData(self.viewModel.buildersRows)
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
            _ = self.headerViewModel.configured(pageDetailsViewModels: viewModels)
        }
    }
    
    private func setupHeaderPageDetailsEvents() {
        self.viewModel.$userEvent.safelyUnwrapOptionals().sink { [weak self] (value) in
            self?.process(event: value)
        }.store(in: &self.subscriptions)
    }
}

// MARK: - Set Focus
private extension Namespace.ViewController {
    func scrollAndFocusOnFocusedBlock() {
        guard let dataSource = self.dataSource else { return }
        let snapshot = dataSource.snapshot()
        let userSession = self.viewModel.documentViewModel.getUserSession()
        let id = userSession?.firstResponder()
        let focusedAt = userSession?.focusAt()
        if let id = id, let focusedAt = focusedAt {
            let itemIdentifiers = snapshot.itemIdentifiers(inSection: .first)
            if let index = itemIdentifiers.firstIndex(where: { (value) -> Bool in
                value.builder?.blockId == id
            }) {
                (itemIdentifiers[index].blockBuilder as? BlocksViews.New.Text.Base.ViewModel)?.set(focus: .init(position: focusedAt, completion: {_ in }))
                userSession?.unsetFocusAt()
                userSession?.unsetFirstResponder()
            }
        }
    }
    func tryFocusItem(at indexPath: IndexPath) {
        guard !self.viewModel.selectionEnabled() else { return }
        guard let dataSource = self.dataSource else { return }
        let snapshot = dataSource.snapshot()
        let userSession = self.viewModel.documentViewModel.getUserSession()
        let itemIdentifiers = snapshot.itemIdentifiers(inSection: .first)
        /// Since we are working only with one section, we could safely iterate over array of items.
        let index = indexPath.row
        let item = itemIdentifiers[index]
        if let textItem = item.blockBuilder as? ViewModel.BlocksViewsNamespace.Text.Base.ViewModel {
            _ = textItem.getBlock().blockModel.information.id
            
            let collectionViewElementPosition: UICollectionView.ScrollPosition = .centeredVertically
            let focusedAt: TextView.UIKitTextView.ViewModel.Focus.Position = .end
            let indexPath: IndexPath = .init(row: index, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: collectionViewElementPosition, animated: true)
            textItem.set(focus: .init(position: focusedAt, completion: {_ in }))
            userSession?.unsetFocusAt()
            userSession?.unsetFirstResponder()
        }
    }
}

// MARK: - Initial Update data
extension Namespace.ViewController {
    private func updateView() {
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }
        
    private func updateData(_ rows: [ViewModel.Row]) {
        guard let theDataSource = self.dataSource else { return }
                
        var snapshot = NSDiffableDataSourceSnapshot<ViewModel.Section, ViewModel.Row>()
        snapshot.appendSections([ViewModel.Section.first])
        snapshot.appendItems(rows)
        
        /// TODO: Think about post update and set focus synergy.
        /// Maybe we should sync set focus here in completion?
        ///
        ///
        let scrollAndFocusCompletion: () -> () = { [weak self] in
            self?.scrollAndFocusOnFocusedBlock()
        }
        if self.developerOptions.current.workflow.mainDocumentEditor.listView.shouldAnimateRowsInsertionAndDeletion {
            theDataSource.apply(snapshot, animatingDifferences: true, completion: scrollAndFocusCompletion)
        }
        else {
            UIView.performWithoutAnimation {
                theDataSource.apply(snapshot, animatingDifferences: true, completion: scrollAndFocusCompletion)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension Namespace.ViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didSelectBlock(at: indexPath)
    }
}

// MARK: TODO: Remove later.
extension Namespace.ViewController {
    func getViewModel() -> ViewModel { self.viewModel }
}

// MARK: - EditorModuleDocumentViewInput

extension Namespace.ViewController: EditorModuleDocumentViewInput {
    func setFocus(at index: Int) {
        self.tryFocusItem(at: IndexPath(row: index, section: 1))
    }
}
