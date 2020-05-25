//
//  DocumentView+ViewController.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI // Required by current ViewModels.
import Combine
import os

private extension Logging.Categories {
    static let documentViewController: Self = "TextEditor.DocumentViewController"
}

// MARK: - This is view controller that will handle everything for us.
class DocumentViewController: UIViewController {
    typealias ViewModel = DocumentViewModel
    
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
        var tableView = UITableView()
        var tableViewController = UITableViewController()
        tableView = tableViewController.tableView
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

// MARK: - HeaderView PageDetails
extension DocumentViewController {
    private func process(event: DocumentViewModel.UserEvent) {
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
extension DocumentViewController {
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
extension DocumentViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // TODO: Redone on top of Combine.
        // We should fire event, when somebody is subscribed buildersRows.
        self.updateData(self.viewModel.buildersRows)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Setup
extension DocumentViewController {
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
        tableView.register(DocumentViewCells.Cell.self, forCellReuseIdentifier: DocumentViewCells.Cell.cellReuseIdentifier())
    }

    private func setupDataSource() {
        self.dataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Row>.init(tableView: tableView, cellProvider: { (tableView, indexPath, entry) -> UITableViewCell? in
            let useUIKit = !self.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldEmbedSwiftUIIntoCell
            let shouldShowIndent = self.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldShowCellsIndentation
            if let cell = tableView.dequeueReusableCell(withIdentifier: DocumentViewCells.Cell.cellReuseIdentifier(), for: indexPath) as? DocumentViewCells.Cell {
                _ = cell.configured(useUIKit: useUIKit).configured(shouldShowIndent: shouldShowIndent).configured(entry)
                return cell
            }
            return UITableViewCell.init()
        })
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
extension DocumentViewController {
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
private extension DocumentViewController {
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
extension DocumentViewController {
    @objc func createEmptyBlockOnTapIfListIsEmptyGestureRecognizerHandler() {
        self.viewModel.handlingTapIfEmpty()
    }
}

// MARK: - Initial Update data
extension DocumentViewController {
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
}

// MARK: - UITableViewDataSource
extension DocumentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.countOfElements(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.viewModel.element(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: DocumentViewCells.Cell.cellReuseIdentifier(), for: indexPath)
        if let cell = cell as? DocumentViewCells.Cell {
            _ = cell.configured(item)
            return cell
        }
        return .init()
    }
}

// MARK: - UITableViewDelegate
extension DocumentViewController: UITableViewDelegate {
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
