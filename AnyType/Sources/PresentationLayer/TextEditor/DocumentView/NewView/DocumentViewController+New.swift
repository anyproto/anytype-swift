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

// MARK: - HeaderView
extension Namespace.DocumentViewController {
    typealias HeaderView = DocumentViewController.HeaderView
}

// MARK: - This is view controller that will handle everything for us.
extension Namespace {
    class DocumentViewController: UIViewController {
        typealias ViewModel = DocumentModule.DocumentViewModel
        
        /// Environment
        @Environment(\.developerOptions) private var developerOptions
        
        /// DataSource
        private var dataSource: UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Row>?

        /// Model
        private var viewModel: ViewModel
        private var headerViewModel: HeaderView.ViewModel = .init()
        lazy var headerViewModelPublisher: AnyPublisher<HeaderView.UserAction, Never> = {
            self.headerViewModel.$userAction.safelyUnwrapOptionals().eraseToAnyPublisher()
        }()
        
        /// Selection
        private var selectionHandler: SelectionHandler = .init()
        lazy var selectionHandlerPublisher: AnyPublisher<SelectionHandler.SelectionAction, Never> = {
            self.selectionHandler.userAction
        }()
        
        /// Routing
        /// TODO: Remove it later.
        private var router: DocumentViewRoutingOutputProtocol?

        /// Combine
        private var subscriptions: Set<AnyCancellable> = []

        /// Decorations of UIKit
        private var cellHeightsStorage: CellsHeightsStorage = .init()

        /// Actions
        private var tableViewTapGestureRecognizer: UITapGestureRecognizer = .init()

        /// Views
        private lazy var tableView: UITableView = {
            let tableViewController = UITableViewController()
            guard let tableView = tableViewController.tableView else {
                /// Actually, not called, but is required by Swift type system.
                return .init()
            }
            tableView.translatesAutoresizingMaskIntoConstraints = false

            // add tvc to parent vc
            self.view.addSubview(tableView)
            self.addChild(tableViewController)
            tableViewController.didMove(toParent: self)

            return tableView
        }()

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

// MARK: - Selection Handling
extension Namespace.DocumentViewController {
    private func configured(selectionEventsPublisher: AnyPublisher<DocumentModule.SelectionEvent, Never>) -> Self {
        _ = self.selectionHandler.configured(tableView: self.tableView).configured(selectionEventPublisher: selectionEventsPublisher)
        return self
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

// MARK: - Routing
extension Namespace.DocumentViewController {
    private func handleRouting(action: DocumentViewRouting.OutputEvent) {
        switch action {
        case let .showViewController(viewController):
            self.present(viewController, animated: true, completion: {})
        case let .pushViewController(viewController):
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    /// WARNING!
    /// This method also retain router.
    /// Refactor it later.
    func subscribeOnRouting(_ router: DocumentViewRoutingOutputProtocol) {
        let logger = Logging.createLogger(category: .documentViewController)
        os_log(.debug, log: logger, "We should remove router from view controller later.")
        self.router = router
        router.outputEventsPublisher.sink { [weak self] (value) in
            self?.handleRouting(action: value)
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
        self.setupElements()
        self.setupTableView()
        self.setupDataSource()
        self.setupLayout()
        self.setupUserInteractions()
        self.setupInteractions()
        self.setupHeaderPageDetailsEvents()
    }

    private func setupElements() {
        self.view.addSubview(headerView)
        self.view.addSubview(tableView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 0
        tableView.separatorStyle = .none
        // Need for image picker
        tableView.allowsSelection = true

        // register cells.
        tableView.register(Namespace.DocumentViewCells.Cell.self, forCellReuseIdentifier: Namespace.DocumentViewCells.Cell.cellReuseIdentifier())
    }

    private func setupDataSource() {
        self.dataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Row>.init(tableView: tableView, cellProvider: { [weak self] (tableView, indexPath, entry) -> UITableViewCell? in
            let useUIKit = !(self?.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldEmbedSwiftUIIntoCell == true)
            let shouldShowIndent = (self?.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldShowCellsIndentation == true)
            if let cell = tableView.dequeueReusableCell(withIdentifier: Namespace.DocumentViewCells.Cell.cellReuseIdentifier(), for: indexPath) as? Namespace.DocumentViewCells.Cell {
                _ = cell.configured(useUIKit: useUIKit).configured(shouldShowIndent: shouldShowIndent).configured(entry)
                return cell
            }
            return .init()
        })
        self.dataSource?.defaultRowAnimation = .none
        self.tableView.dataSource = self.dataSource
    }

    func setupUserInteractions() {
        self.tableViewTapGestureRecognizer.cancelsTouchesInView = false
        // We should skip gestures for all touches in tableView.headerView
        self.tableView.addGestureRecognizer(self.tableViewTapGestureRecognizer)
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
        
        self.viewModel.anyFieldPublisher.sink(receiveValue: { [weak self] (value) in
            self?.updateView()
        }).store(in: &self.subscriptions)
        
        self.viewModel.fileFieldPublisher.sink(receiveValue: { [weak self] (value) in
            self?.updateView()
        }).store(in: &self.subscriptions)
        
        self.viewModel.anyStylePublisher.sink { [weak self] (value) in
            self?.updateIds(value)
        }.store(in: &self.subscriptions)
        
        /// Selection
        _ = self.configured(selectionEventsPublisher: self.viewModel.selectionEventPublisher())
        self.viewModel.configured(multiSelectionUserActionPublisher: self.selectionHandlerPublisher)
    }

    func configured(_ options: ViewModel.Options) {
        if options.shouldCreateEmptyBlockOnTapIfListIsEmpty {
            self.tableViewTapGestureRecognizer.addTarget(self, action: #selector(createEmptyBlockOnTapIfListIsEmptyGestureRecognizerHandler))
            view.addGestureRecognizer(self.tableViewTapGestureRecognizer)
        }
        else {
            self.tableViewTapGestureRecognizer.removeTarget(self, action: #selector(createEmptyBlockOnTapIfListIsEmptyGestureRecognizerHandler))
            view.removeGestureRecognizer(self.tableViewTapGestureRecognizer)
        }
    }
}

// MARK: Gesture Recognizer
extension Namespace.DocumentViewController {
    @objc func createEmptyBlockOnTapIfListIsEmptyGestureRecognizerHandler() {
        self.viewModel.handlingTapIfEmpty()
    }
}

// MARK: - Initial Update data
extension Namespace.DocumentViewController {
    func updateView() {
        DispatchQueue.main.async {
            // WORKAROUND:
            // In case of jumping rows we should remove animations..
            // well...
            // it works...
            // I guess..
            // Thanks! https://stackoverflow.com/a/51048044/826614
            let lastContentOffset = self.tableView.contentOffset
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.tableView.layer.removeAllAnimations()
            self.tableView.setContentOffset(lastContentOffset, animated: false)
        }
    }
    
    func updateData(_ rows: [ViewModel.Row]) {
        guard let dataSource = self.dataSource else { return }
        
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.deleteSections([ViewModel.Section.first])
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

// MARK: - UITableViewDataSource
extension Namespace.DocumentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.countOfElements(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.viewModel.element(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: Namespace.DocumentViewCells.Cell.cellReuseIdentifier(), for: indexPath)
        if let cell = cell as? Namespace.DocumentViewCells.Cell {
            _ = cell.configured(item)
            return cell
        }
        return .init()
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
