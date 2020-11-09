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

fileprivate typealias Namespace = DocumentModule

private extension Logging.Categories {
    static let documentViewController: Self = "TextEditor.DocumentViewController"
}

// MARK: - This is view controller that will handle everything for us.
extension Namespace {
    class DocumentViewController: UIViewController {
        typealias ViewModel = DocumentModule.DocumentViewModel
        typealias ListDiffableDataSource = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Row>
        typealias ListDiffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<ViewModel.Section, ViewModel.Row>
        typealias TableViewDataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Row>
        typealias CollectionViewDataSource = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Row>
        
        /// Environment
        @Environment(\.developerOptions) private var developerOptions
        
        /// DataSource
        private var dataSource: ListDiffableDataSource?
        private var tableViewDataSource: TableViewDataSource?
        private var collectionViewDataSource: CollectionViewDataSource?

        /// Model
        private var viewModel: ViewModel
        private var headerViewModel: HeaderView.ViewModel = .init()
        lazy var headerViewModelPublisher: AnyPublisher<HeaderView.UserAction, Never> = {
            self.headerViewModel.$userAction.safelyUnwrapOptionals().eraseToAnyPublisher()
        }()
                
        /// Combine
        private var subscriptions: Set<AnyCancellable> = []

        /// Decorations of UIKit
        private var cellHeightsStorage: CellsHeightsStorage = .init()

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
            self.tableView
        }

        private lazy var headerView: DocumentViewController.HeaderView = {
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
extension Namespace.DocumentViewController {
    private func process(event: Namespace.DocumentViewModel.UserEvent) {
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
extension Namespace.DocumentViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // TODO: Redone on top of Combine.
        // We should fire event, when somebody is subscribed buildersRows.
        self.updateData(self.viewModel.buildersRows)
    }
}

// MARK: - Setup
extension Namespace.DocumentViewController {
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
        self.setupTableView()
    }
    
    private func setupTableView() {
        
        let viewController = UITableViewController(style: .grouped)
        self.addChild(viewController)
        
        if let tableView = viewController.tableView {
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
        
        self.tableViewController = viewController

        // register cells(?)
        // register them as CellRegistration
        self.tableView?.register(Namespace.DocumentViewCells.TableViewCell.self, forCellReuseIdentifier: Namespace.DocumentViewCells.TableViewCell.cellReuseIdentifier())
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.backgroundColor = .white
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        return layout
    }
    
    private func setupCollectionView() {
        
        let viewController = UICollectionViewController(collectionViewLayout: self.createLayout())
        self.addChild(viewController)
        
        if let collectionView = viewController.collectionView {
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(collectionView)
            viewController.didMove(toParent: self)
            
            collectionView.backgroundView = .init()
            collectionView.backgroundColor = .white
            collectionView.allowsSelection = true
            collectionView.delegate = self
        }
        
        self.collectionViewController = viewController

        // register cells(?)
        // register them as CellRegistration
        self.collectionView?.register(Namespace.DocumentViewCells.CollectionViewCell.self, forCellWithReuseIdentifier: Namespace.DocumentViewCells.CollectionViewCell.cellReuseIdentifier())
    }
        
    private func setupTableViewDataSource() {
        typealias Cells = Namespace.DocumentViewCells.ContentConfigurations
        func cellIdentifier(for builder: BlocksViews.New.Base.ViewModel) -> String? {
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
        
        guard let listView = self.tableView else { return }
        
        listView.register(Cells.Text.Text.Table.self, forCellReuseIdentifier: Cells.Text.Text.Table.cellReuseIdentifier())
        
        listView.register(Cells.File.File.Table.self, forCellReuseIdentifier: Cells.File.File.Table.cellReuseIdentifier())
        listView.register(Cells.File.Image.Table.self, forCellReuseIdentifier: Cells.File.Image.Table.cellReuseIdentifier())
        
        listView.register(Cells.Bookmark.Bookmark.Table.self, forCellReuseIdentifier: Cells.Bookmark.Bookmark.Table.cellReuseIdentifier())
        
        listView.register(Cells.Other.Divider.Table.self, forCellReuseIdentifier: Cells.Other.Divider.Table.cellReuseIdentifier())
        
        listView.register(Cells.Link.PageLink.Table.self, forCellReuseIdentifier: Cells.Link.PageLink.Table.cellReuseIdentifier())

        listView.register(Cells.Unknown.Label.Table.self, forCellReuseIdentifier: Cells.Unknown.Label.Table.cellReuseIdentifier())

        self.tableViewDataSource = TableViewDataSource.init(tableView: listView, cellProvider: { [weak self] (view, indexPath, entry) -> UITableViewCell? in
            let useUIKit = !(self?.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldEmbedSwiftUIIntoCell == true)
            let shouldShowIndent = (self?.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldShowCellsIndentation == true)
            
            let ourBuilder = entry.builder as! BlocksViews.New.Base.ViewModel
            let cell = cellIdentifier(for: ourBuilder).flatMap({view.dequeueReusableCell(withIdentifier: $0, for: indexPath)})
            
            let configuration = ourBuilder.buildContentConfiguration()
            cell?.contentConfiguration = configuration
            return cell
//            switch view.dequeueReusableCell(withIdentifier: Namespace.DocumentViewCells.TableViewCell.cellReuseIdentifier(), for: indexPath) {
//            case let cell as Namespace.DocumentViewCells.TableViewCell: return cell.configured(useUIKit: useUIKit).configured(shouldShowIndent: shouldShowIndent).configured(entry)
//            default: return nil
//            }
        })
        
        (self.tableViewDataSource)?.defaultRowAnimation = .none
    }
    
    private func setupCollectionViewDataSource() {
        guard let listView = self.collectionView else { return }
        
        let imageCellRegistration: UICollectionView.CellRegistration<Namespace.DocumentViewCells.ContentConfigurations.File.Image.Collection, ViewModel.Row> =
            .init { (cell, indexPath, row) in
            let configuration = (row.builder as! BlocksViews.New.Base.ViewModel).buildContentConfiguration()
            cell.contentConfiguration = configuration
        }
        
        let dividerCellRegistration: UICollectionView.CellRegistration<Namespace.DocumentViewCells.ContentConfigurations.Other.Divider.Collection, ViewModel.Row>
            = .init { (cell, indexPath, row) in
            let configuration = (row.builder as! BlocksViews.New.Base.ViewModel).buildContentConfiguration()
            cell.contentConfiguration = configuration
        }
        
        self.collectionViewDataSource = CollectionViewDataSource.init(collectionView: listView, cellProvider: { [weak self] (view, indexPath, entry) -> UICollectionViewCell? in
            let useUIKit = !(self?.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldEmbedSwiftUIIntoCell == true)
            let shouldShowIndent = (self?.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldShowCellsIndentation == true)
            switch (entry.builder as! BlocksViews.New.Base.ViewModel).getBlock().blockModel.information.content {
            case let .file(file) where file.contentType == .image: return view.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: entry)
            case .divider:
                let cell = view.dequeueConfiguredReusableCell(using: dividerCellRegistration, for: indexPath, item: entry)
                return cell
            default: break
            }
            
            switch view.dequeueReusableCell(withReuseIdentifier: Namespace.DocumentViewCells.CollectionViewCell.cellReuseIdentifier(), for: indexPath) {
            case let cell as Namespace.DocumentViewCells.CollectionViewCell: return cell.configured(useUIKit: useUIKit).configured(shouldShowIndent: shouldShowIndent).configured(entry)
            default: return nil
            }
        })
    }

    private func setupDataSource() {
        self.setupTableViewDataSource()
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

// MARK: - CellsHeightsStorage
extension Namespace.DocumentViewController {
    class CellsHeightsStorage {
        private var storage: [IndexPath: CGFloat] = [:]
        
        func height(at: IndexPath) -> CGFloat {
            return storage[at] ?? UITableView.automaticDimension
        }
        
        func set(height: CGFloat, at: IndexPath) {
            storage[at] = height
        }
    }
}

// MARK: - Configuration
/// Warning! Call these methods only after `viewDidLoad`
private extension Namespace.DocumentViewController {
    func configured() {
        self.viewModel.$buildersRows.sink(receiveValue: { [weak self] (value) in
            self?.updateData(value)
        }).store(in: &self.subscriptions)
                
        self.viewModel.anyFieldPublisher.receive(on: RunLoop.main).sink(receiveValue: { [weak self] (value) in
            self?.updateView()
        }).store(in: &self.subscriptions)

//        self.viewModel.fileFieldPublisher.receive(on: RunLoop.main).sink(receiveValue: { [weak self] (value) in
//            return;
//            self?.updateView()
//        }).store(in: &self.subscriptions)
        
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
extension Namespace.DocumentViewController {
    @objc func tapOnListViewGestureRecognizerHandler() {
        self.viewModel.handlingTapIfEmpty()
    }
}

// MARK: - Initial Update data
extension Namespace.DocumentViewController {
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
    }
    
    func updateData(_ rows: [ViewModel.Row]) {
        guard let dataSource = self.tableViewDataSource else { return }
        
        var snapshot = ListDiffableDataSourceSnapshot.init()
        snapshot.appendSections([ViewModel.Section.first])
        snapshot.appendItems(rows)
        dataSource.apply(snapshot)
    }
    
    func updateIds(_ ids: [String]) {
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
extension Namespace.DocumentViewController: UICollectionViewDelegate {
    // WORKAROUND:
    // In case of jumping rows we should also calculate estimated sizes of cells by storing exact sizes of cells.
    // well...
    // it works...
    // I guess..
    // Thanks! https://stackoverflow.com/a/38729250/826614
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.cellHeightsStorage.set(height: cell.frame.size.height, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didSelectBlock(at: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension Namespace.DocumentViewController: UITableViewDelegate {
    // WORKAROUND:
    // In case of jumping rows we should also calculate estimated sizes of cells by storing exact sizes of cells.
    // well...
    // it works...
    // I guess..
    // Thanks! https://stackoverflow.com/a/38729250/826614
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cellHeightsStorage.set(height: cell.frame.size.height, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeightsStorage.height(at: indexPath)
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.didSelectBlock(at: indexPath)
    }
}

// MARK: Debug
extension Namespace.DocumentViewController {
    override var debugDescription: String {
        "\(String(describing: Self.self)) -> \(self.viewModel.debugDescription)"
    }
}

// MARK: TODO: Remove later.
extension Namespace.DocumentViewController {
    func getViewModel() -> ViewModel { self.viewModel }
}
