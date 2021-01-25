//
//  DocumentViewController+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI // Required by current ViewModels.
import Combine
import os

fileprivate typealias Namespace = EditorModule.Document

private extension Logging.Categories {
    static let documentViewController: Self = "TextEditor.DocumentViewController"
}

private protocol ListDataSource {
    associatedtype SectionIdentifierType: Hashable
    associatedtype ItemIdentifierType: Hashable
    func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, animatingDifferences: Bool, completion: (() -> Void)?)
    func snapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
}

extension UICollectionViewDiffableDataSource: ListDataSource {}
extension UITableViewDiffableDataSource: ListDataSource {}
private extension Namespace.ViewController {
    struct AnyListDataSource<SectionIdentifierType, ItemIdentifierType>: ListDataSource where SectionIdentifierType: Hashable, ItemIdentifierType: Hashable {
        private var applyFunction: (NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, Bool, (() -> Void)?) -> ()
        private var snapshotFunction: () -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
        init<T: ListDataSource>(_ value: T) where T.SectionIdentifierType == SectionIdentifierType, T.ItemIdentifierType == ItemIdentifierType {
            self.applyFunction = value.apply
            self.snapshotFunction = value.snapshot
        }
        /// ListDataSource
        func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, animatingDifferences: Bool, completion: (() -> Void)?) {
            self.applyFunction(snapshot, animatingDifferences, completion)
        }
        func snapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
            self.snapshotFunction()
        }
    }
}

private extension Namespace.ViewController {
    class TableViewDelegate: NSObject, UITableViewDelegate {
        private class HeightsStorage {
            private var storage: [IndexPath: CGFloat] = [:]
            
            func get(at: IndexPath) -> CGFloat? {
                return storage[at]
            }
            
            func set(height: CGFloat, at: IndexPath) {
                storage[at] = height
            }
        }
        /// Decorations of UIKit
        private var heightsStorage: HeightsStorage = .init()
        
        /// UITableViewDelegate
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            self.heightsStorage.set(height: cell.frame.size.height, at: indexPath)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            self.heightsStorage.get(at: indexPath) ?? UITableView.automaticDimension
        }
    }
    class CollectionViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        private class SizesStorage {
            typealias Size = CGSize
            private var storage: [IndexPath: Size] = [:]
            
            func get(at: IndexPath) -> Size? {
                return storage[at]
            }
            
            func set(height: Size, at: IndexPath) {
                storage[at] = height
            }
        }
        private var sizesStorage: SizesStorage = .init()
        
        /// UICollectionViewDelegateFlowLayout
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            self.sizesStorage.set(height: cell.frame.size, at: indexPath)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            self.sizesStorage.get(at: indexPath) ?? UICollectionViewFlowLayout.automaticSize
        }
    }
}

private extension Namespace.ViewController {
    class OurTableViewController: UITableViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
        }
    }
}

// MARK: - This is view controller that will handle everything for us.
extension Namespace {
    class ViewController: UIViewController {
        private typealias ListDiffableDataSource = AnyListDataSource<ViewModel.Section, ViewModel.Row>
        typealias ListDiffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<ViewModel.Section, ViewModel.Row>
        typealias TableViewDataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Row>
        typealias CollectionViewDataSource = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Row>
        
        /// Environment
        @Environment(\.developerOptions) private var developerOptions
        
        /// DataSource
        private var dataSource: ListDiffableDataSource?
        private var tableViewDataSource: TableViewDataSource? {
            didSet {
                if let value = self.tableViewDataSource {
                    self.dataSource = .init(value)
                }
            }
        }
        private var collectionViewDataSource: CollectionViewDataSource? {
            didSet {
                if let value = self.collectionViewDataSource {
                    self.dataSource = .init(value)
                }
            }
        }

        /// Model
        private var viewModel: ViewModel
        private var headerViewModel: HeaderView.ViewModel = .init()
        lazy var headerViewModelPublisher: AnyPublisher<HeaderView.UserAction, Never> = {
            self.headerViewModel.$userAction.safelyUnwrapOptionals().eraseToAnyPublisher()
        }()
                
        /// Combine
        private var subscriptions: Set<AnyCancellable> = []
        
        /// Delegates
        private var tableViewDelegate: UITableViewDelegate = TableViewDelegate.init()
        private var collectionViewDelegate: UICollectionViewDelegateFlowLayout & UICollectionViewDelegate = CollectionViewDelegate.init()

        /// Actions
        private var listViewTapGestureRecognizer: UITapGestureRecognizer = .init()

        /// Views
        private var collectionViewController: UICollectionViewController?
        private var collectionView: UICollectionView? {
            self.collectionViewController?.collectionView
        }
        
        private var tableViewController: UITableViewController?
        private var tableView: UITableView? {
            self.tableViewController?.tableView
        }
        
        private var listView: UIView? {
            self.collectionView ?? self.tableView
        }

        private lazy var headerView: HeaderView = {
            .init(viewModel: self.headerViewModel)
        }()

        /// Initialization
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - HeaderView PageDetails
extension Namespace.ViewController {
    private func process(event: Namespace.ViewController.ViewModel.UserEvent) {
        switch event {
        case .pageDetailsViewModelsDidSet:
            let viewModels = self.viewModel.pageDetailsViewModels.filter({[.iconEmoji, .title].contains($0.key)})
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

// MARK: - View lifecycle
extension Namespace.ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // TODO: Redone on top of Combine.
        // We should fire event, when somebody is subscribed buildersRows.
        self.updateData(self.viewModel.buildersRows)
    }
}

// MARK: - Setup
extension Namespace.ViewController {
    private func setupUI() {
        self.setupListView()
        self.setupElements()
        self.setupDataSource()
        self.setupLayout()
        self.setupUserInteractions()
        self.setupInteractions()
        self.setupHeaderPageDetailsEvents()
    }

    private func setupElements() {
        self.view.addSubview(self.headerView)
    }

    private func setupLayout() {
        if let superview = self.headerView.superview {
            let view = self.headerView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
        if let view = self.listView, let superview = view.superview {
            let topView = self.headerView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: topView.bottomAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    /// ListViews
    private func setupListView() {
        if self.developerOptions.current.workflow.mainDocumentEditor.listView.shouldUseCollectionView {
            self.setupCollectionView()
        }
        else {
            self.setupTableView()
        }
    }
    
    private func setupTableView() {
        
        let viewController: UITableViewController = OurTableViewController(style: .grouped)
        self.addChild(viewController)
        self.tableViewController = viewController

        if let tableView = self.tableView {
            tableView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(tableView)
            viewController.didMove(toParent: self)
            
            tableView.contentInset = .zero
            tableView.backgroundView = .init()
            tableView.backgroundColor = .white
            tableView.allowsSelection = true
            tableView.delegate = self
            tableView.estimatedRowHeight = 60
            tableView.rowHeight = UITableView.automaticDimension
            tableView.sectionHeaderHeight = 0
            tableView.separatorStyle = .none
            // Need for image picker
        }
        
        // register cells(?)
        // register them as CellRegistration
        self.tableView?.register(EditorModule.Document.Cells.TableViewCell.self, forCellReuseIdentifier: EditorModule.Document.Cells.TableViewCell.cellReuseIdentifier())
    }
    
    private func createFlowLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(40))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func createListLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.backgroundColor = .white
        listConfiguration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        
        return layout
    }
    
    private func createLayout() -> UICollectionViewLayout {
        self.createFlowLayout()
    }
    
    private func setupCollectionView() {
        
        let viewController = UICollectionViewController(collectionViewLayout: self.createLayout())
        self.addChild(viewController)
        self.collectionViewController = viewController

        if let collectionView = self.collectionView {
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(collectionView)
            viewController.didMove(toParent: self)
            
            collectionView.backgroundView = .init()
            collectionView.backgroundColor = .white
            collectionView.allowsSelection = true
            collectionView.delegate = self
        }

        // register cells(?)
        // register them as CellRegistration
        self.collectionView?.register(EditorModule.Document.Cells.CollectionViewCell.self, forCellWithReuseIdentifier: EditorModule.Document.Cells.CollectionViewCell.cellReuseIdentifier())
    }
    
    private typealias Cells = EditorModule.Document.Cells.ContentConfigurations
    
    enum CellIdentifierConverter {
        static func identifier(for builder: BlocksViews.New.Base.ViewModel) -> String? {
            switch builder.getBlock().blockModel.information.content {
            case let .text(text) where text.contentType == .text:
                return Cells.Text.Text.Table.cellReuseIdentifier()
            case let .file(file) where file.contentType == .file:
                return Cells.File.File.Table.cellReuseIdentifier()
            case let .file(file) where file.contentType == .image:
                return Cells.File.Image.Table.cellReuseIdentifier()
            case .bookmark:
                return Cells.Bookmark.Bookmark.Table.cellReuseIdentifier()
            case .divider:
                return Cells.Other.Divider.Table.cellReuseIdentifier()
            case let .link(value) where value.style == .page:
                return Cells.Link.PageLink.Table.cellReuseIdentifier()
            default:
                return Cells.Unknown.Label.Table.cellReuseIdentifier()
            }
        }
    }
    
    private func setupTableViewDataSource() {
        
        guard let listView = self.tableView else { return }
        
        listView.register(Cells.Text.Text.Table.self, forCellReuseIdentifier: Cells.Text.Text.Table.cellReuseIdentifier())
        
        listView.register(Cells.File.File.Table.self, forCellReuseIdentifier: Cells.File.File.Table.cellReuseIdentifier())
        listView.register(Cells.File.Image.Table.self, forCellReuseIdentifier: Cells.File.Image.Table.cellReuseIdentifier())
        
        listView.register(Cells.Bookmark.Bookmark.Table.self, forCellReuseIdentifier: Cells.Bookmark.Bookmark.Table.cellReuseIdentifier())
        
        listView.register(Cells.Other.Divider.Table.self, forCellReuseIdentifier: Cells.Other.Divider.Table.cellReuseIdentifier())
        
        listView.register(Cells.Link.PageLink.Table.self, forCellReuseIdentifier: Cells.Link.PageLink.Table.cellReuseIdentifier())

        listView.register(Cells.Unknown.Label.Table.self, forCellReuseIdentifier: Cells.Unknown.Label.Table.cellReuseIdentifier())

        self.tableViewDataSource = TableViewDataSource.init(tableView: listView, cellProvider: { [weak self] (view, indexPath, entry) -> UITableViewCell? in
            _ = !(self?.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldEmbedSwiftUIIntoCell == true)
            _ = (self?.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldShowCellsIndentation == true)
            
            let ourBuilder = entry.builder as! BlocksViews.New.Base.ViewModel
            let cell = CellIdentifierConverter.identifier(for: ourBuilder).flatMap({view.dequeueReusableCell(withIdentifier: $0, for: indexPath)})
            
            let configuration = ourBuilder.buildContentConfiguration()
            cell?.contentConfiguration = configuration
            return cell
        })
        
        (self.tableViewDataSource)?.defaultRowAnimation = .none
    }
    
    private func setupCollectionViewDataSource() {
        guard let listView = self.collectionView else { return }
        
        listView.register(Cells.Text.Text.Collection.self, forCellWithReuseIdentifier: Cells.Text.Text.Table.cellReuseIdentifier())
        
        listView.register(Cells.File.File.Collection.self, forCellWithReuseIdentifier: Cells.File.File.Table.cellReuseIdentifier())
        listView.register(Cells.File.Image.Collection.self, forCellWithReuseIdentifier: Cells.File.Image.Table.cellReuseIdentifier())
        
        listView.register(Cells.Bookmark.Bookmark.Collection.self, forCellWithReuseIdentifier: Cells.Bookmark.Bookmark.Table.cellReuseIdentifier())
        
        listView.register(Cells.Other.Divider.Collection.self, forCellWithReuseIdentifier: Cells.Other.Divider.Table.cellReuseIdentifier())
        
        listView.register(Cells.Link.PageLink.Collection.self, forCellWithReuseIdentifier: Cells.Link.PageLink.Table.cellReuseIdentifier())

        listView.register(Cells.Unknown.Label.Collection.self, forCellWithReuseIdentifier: Cells.Unknown.Label.Table.cellReuseIdentifier())

        
        self.collectionViewDataSource = CollectionViewDataSource.init(collectionView: listView, cellProvider: { [weak self] (view, indexPath, entry) -> UICollectionViewCell? in
            _ = !(self?.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldEmbedSwiftUIIntoCell == true)
            _ = (self?.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldShowCellsIndentation == true)
            let ourBuilder = entry.builder as! BlocksViews.New.Base.ViewModel
            let cell = CellIdentifierConverter.identifier(for: ourBuilder).flatMap({view.dequeueReusableCell(withReuseIdentifier: $0, for: indexPath)})
            
            let configuration = ourBuilder.buildContentConfiguration()
            cell?.contentConfiguration = configuration
            return cell
        })
    }

    private func setupDataSource() {
        if self.developerOptions.current.workflow.mainDocumentEditor.listView.shouldUseCollectionView {
            self.setupCollectionViewDataSource()
        }
        else {
            self.setupTableViewDataSource()
        }
    }

    func setupUserInteractions() {
        self.listViewTapGestureRecognizer.cancelsTouchesInView = false
        // We should skip gestures for all touches in tableView.headerView
        self.listView?.addGestureRecognizer(self.listViewTapGestureRecognizer)
    }

    func setupInteractions() {
        self.configured()
        self.viewModel.$options.sink(receiveValue: { [weak self] (options) in
            self?.configured(options)
        }).store(in: &self.subscriptions)
    }
}

// MARK: - Configuration
/// Warning! Call these methods only after `viewDidLoad`
private extension Namespace.ViewController {
    func configured() {
        self.viewModel.$buildersRows.sink(receiveValue: { [weak self] (value) in
            self?.updateData(value)
        }).store(in: &self.subscriptions)

        self.viewModel.publicSizeDidChangePublisher.receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.updateView()
        }.store(in: &self.subscriptions)

        self.viewModel.anyStylePublisher.sink { [weak self] (value) in
            self?.updateIds(value)
        }.store(in: &self.subscriptions)     
    }

    func configured(_ options: ViewModel.Options) {
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

// MARK: Gesture Recognizer
extension Namespace.ViewController {
    @objc func tapOnListViewGestureRecognizerHandler() {
        self.viewModel.handlingTapIfEmpty()
    }
}

// MARK: - Set Focus
private extension Namespace.ViewController {
    func scrollAndFocusOnFocusedBlock() {
        guard let dataSource = self.dataSource else { return }
        let snapshot = dataSource.snapshot()
        let userSession = self.viewModel.rootModel?.blocksContainer.userSession
        let id = userSession?.firstResponder()
        let focusedAt = userSession?.focusAt()
        print("id: \(String(describing: id)) focusedAt: \(String(describing: focusedAt))")
        if let id = id, let focusedAt = focusedAt {
            let itemIdentifiers = snapshot.itemIdentifiers(inSection: .first)
            if let index = itemIdentifiers.firstIndex(where: { (value) -> Bool in
                value.builder?.blockId == id
            }) {
                let tableViewScrollPosition: UITableView.ScrollPosition
                switch focusedAt {
                case .beginning: tableViewScrollPosition = .middle
                default: tableViewScrollPosition = .middle
                }
                let collectionViewScrollPosition: UICollectionView.ScrollPosition
                switch focusedAt {
                case .beginning: collectionViewScrollPosition = .centeredVertically
                default: collectionViewScrollPosition = .centeredVertically
                }
                
                let indexPath: IndexPath = .init(row: index, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: tableViewScrollPosition, animated: true)
                self.collectionView?.scrollToItem(at: indexPath, at: collectionViewScrollPosition, animated: true)
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
        let userSession = self.viewModel.rootModel?.blocksContainer.userSession
        let itemIdentifiers = snapshot.itemIdentifiers(inSection: .first)
        /// Since we are working only with one section, we could safely iterate over array of items.
        let index = indexPath.row
        let item = itemIdentifiers[index]
        if let textItem = item.blockBuilder as? ViewModel.BlocksViewsNamespace.Text.Base.ViewModel {
            _ = textItem.getBlock().blockModel.information.id
            
            let tableViewElementPosition: UITableView.ScrollPosition = .middle
            let collectionViewElementPosition: UICollectionView.ScrollPosition = .centeredVertically
//            switch focusedAt {
//            case .beginning: elementPosition = .top
//            default: elementPosition = .bottom
//            }
            let focusedAt: TextView.UIKitTextView.ViewModel.Focus.Position = .end
            let indexPath: IndexPath = .init(row: index, section: 0)
            self.tableView?.scrollToRow(at: indexPath, at: tableViewElementPosition, animated: true)
            self.collectionView?.scrollToItem(at: indexPath, at: collectionViewElementPosition, animated: true)
            textItem.set(focus: .init(position: focusedAt, completion: {_ in }))
            userSession?.unsetFocusAt()
            userSession?.unsetFirstResponder()
        }
    }
}

// MARK: - Initial Update data
extension Namespace.ViewController {
    func updateView() {
        // WORKAROUND:
        // In case of jumping rows we should remove animations..
        // well...
        // it works...
        // I guess..
        // Thanks! https://stackoverflow.com/a/51048044/826614
        if let tableView = self.tableView {
            let lastContentOffset = tableView.contentOffset
            tableView.beginUpdates()
            tableView.endUpdates()
            tableView.layer.removeAllAnimations()
            tableView.setContentOffset(lastContentOffset, animated: false)
        }
        else if let collectionView = self.collectionView {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
        
    func updateData(_ rows: [ViewModel.Row]) {
        guard let theDataSource = self.dataSource else { return }
        
        /// TODO: Add
        /// Check if we about to delete block.
        /// In this case we should first focus position and then apply snapshot.
        /// Otherwise, if we need to insert item, we should first insert everything and
        /// on completion set focus.
        ///
        self.scrollAndFocusOnFocusedBlock()
        
        var snapshot = ListDiffableDataSourceSnapshot.init()
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
//                updateDataSource()
            }
        }
    }
    
    func updateIds(_ ids: [String]) {
        /// We should find ids and update them.
        /// For that, we should use data.
        ///
        self.updateData(self.viewModel.buildersRows)
//        guard let dataSource = self.dataSource else { return }
//        var snapshot = dataSource.snapshot()
//        let set: Set<String> = .init(ids)
//        let updatedEntries = self.viewModel.buildersRows.filter { (value) -> Bool in
//            guard let id = value.builder?.blockId else { return false }
//            return set.contains(id)
//        }
//
//        let newEntries = updatedEntries.map({$0.rebuilded()})
//
//        snapshot.reloadItems(newEntries)
//        dataSource.apply(snapshot)
    }
}

// MARK: - UICollectionViewDelegate
extension Namespace.ViewController: UICollectionViewDelegate {
    // WORKAROUND:
    // In case of jumping rows we should also calculate estimated sizes of cells by storing exact sizes of cells.
    // well...
    // it works...
    // I guess..
    // Thanks! https://stackoverflow.com/a/38729250/826614
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.collectionViewDelegate.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didSelectBlock(at: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension Namespace.ViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
////        if self.developerOptions.current.workflow.mainDocumentEditor.listView.shouldUseCellsCaching {
////            return self.collectionViewDelegate.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? .zero
////        }
//        return .zero
//    }
}

// MARK: - UITableViewDelegate
extension Namespace.ViewController: UITableViewDelegate {
    // WORKAROUND:
    // In case of jumping rows we should also calculate estimated sizes of cells by storing exact sizes of cells.
    // well...
    // it works...
    // I guess..
    // Thanks! https://stackoverflow.com/a/38729250/826614
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tableViewDelegate.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tryFocusItem(at: indexPath)
        self.viewModel.didSelectBlock(at: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.developerOptions.current.workflow.mainDocumentEditor.listView.shouldUseCellsCaching {
            return self.tableViewDelegate.tableView?(tableView, heightForRowAt: indexPath) ?? UITableView.automaticDimension
        }
        return UITableView.automaticDimension
    }
}

// MARK: Debug
extension Namespace.ViewController {
    override var debugDescription: String {
        "\(String(describing: Self.self)) -> \(self.viewModel.debugDescription)"
    }
}

// MARK: TODO: Remove later.
extension Namespace.ViewController {
    func getViewModel() -> ViewModel { self.viewModel }
}
