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

// MARK: - This is view controller that will handle everything for us.
class DocumentViewController: UIViewController {
    typealias ViewModel = DocumentViewModel
    
    @Environment(\.developerOptions) var developerOptions
    
    var contentView: UIView?
    var tableView: UITableViewController?
    
    var dataSource: UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Row>?
    
    var model: ViewModel?
    
    var subscriptions: Set<AnyCancellable> = []
    
    var cellHeightsStorage: CellsHeightsStorage = .init()
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

// MARK: - Navigation
extension DocumentViewController {
    class NavigationBar: UINavigationBar {}
}

// MARK: - Configuration
extension DocumentViewController {
    func configured(_ model: ViewModel) -> Self {
        self.model = model
        
        self.model?.$buildersRows.sink(receiveValue: { [weak self] (value) in
            self?.updateData(value)
        }).store(in: &self.subscriptions)
        
        self.model?.anyFieldPublisher.sink(receiveValue: { [weak self] (value) in
            self?.updateView()
        }).store(in: &self.subscriptions)
        
        return self
    }
}

// MARK: - Setup
extension DocumentViewController {
    func setupUI() {
        self.setupElements()
        self.setupTableView()
        self.setupDataSource()
        self.setupNavigation()
        self.addLayout()
    }
    
    func setupNavigation() {
        //        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(reactOnSaveDidPressed))
    }
    
    func setupElements() {
        let contentView = UIView()
        self.contentView = contentView
        self.view.addSubview(contentView)
    }
    
    func setupTableView() {
        let tableView = UITableViewController(style: .grouped)
        
        tableView.tableView.dataSource = self
        tableView.tableView.delegate = self
        if let view = tableView.view {
            self.contentView?.addSubview(view)
        }
        tableView.tableView.estimatedRowHeight = 60
        tableView.tableView.rowHeight = UITableView.automaticDimension
        tableView.tableView.sectionHeaderHeight = 0
        tableView.tableView.separatorStyle = .none
        tableView.tableView.allowsSelection = false
        
        // register cells.
        tableView.tableView.register(DocumentViewCells.Cell.self, forCellReuseIdentifier: DocumentViewCells.Cell.cellReuseIdentifier())
        
        self.tableView = tableView
    }
    
    func setupDataSource() {
        if let tableView = self.tableView?.tableView {
            self.dataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Row>.init(tableView: tableView, cellProvider: { (tableView, indexPath, entry) -> UITableViewCell? in
                let useUIKit = !self.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldEmbedSwiftUIIntoCell
                let shouldShowIndent = self.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldShowCellsIndentation
                let isImage = (entry.builder is ImageBlocksViews.Base.BlockViewModel)
                if let cell = tableView.dequeueReusableCell(withIdentifier: DocumentViewCells.Cell.cellReuseIdentifier(), for: indexPath) as? DocumentViewCells.Cell {
                    _ = cell.configured(useUIKit: useUIKit && !isImage).configured(shouldShowIndent: shouldShowIndent).configured(entry)
                    return cell
                }
                return UITableViewCell.init()
            })
            //            self.dataSource?.defaultRowAnimation = .none
        }
        
        self.tableView?.tableView.dataSource = self.dataSource
    }
    
    func addLayout() {
        if let view = self.contentView, let superview = view.superview {
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        if let view = self.tableView?.tableView, let superview = view.superview {
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            view.translatesAutoresizingMaskIntoConstraints = false
        }
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
            guard let tableView = self.tableView?.tableView else { return }
            let lastContentOffset = tableView.contentOffset
            tableView.beginUpdates()
            tableView.endUpdates()
            tableView.layer.removeAllAnimations()
            tableView.setContentOffset(lastContentOffset, animated: false)
        }
    }
    
    func updateData(_ rows: [ViewModel.Row]) {
        guard let model = self.model, let dataSource = self.dataSource else { return }
                
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.deleteSections([ViewModel.Section.first])
        snapshot.appendSections([ViewModel.Section.first])
        snapshot.appendItems(rows)
        dataSource.apply(snapshot)
    }
}

// MARK: - View lifecycle
extension DocumentViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // TODO: Redone on top of Combine.
        // We should fire event, when somebody is subscribed buildersRows.
        self.updateData(self.model?.buildersRows ?? [])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.viewWillAppear(animated)
    }
}

// MARK: - UITableViewDataSource
extension DocumentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model?.countOfElements(at: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = self.model?.element(at: indexPath) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: DocumentViewCells.Cell.cellReuseIdentifier(), for: indexPath) as? DocumentViewCells.Cell {
                cell.configured(item)
                return cell
            }
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
}
