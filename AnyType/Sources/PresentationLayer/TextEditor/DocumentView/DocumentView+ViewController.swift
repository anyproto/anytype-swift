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

// MARK: This is view controller that will handle everything for us.
extension DocumentView {
    class ViewController: UIViewController {
        typealias ViewModel = DocumentView.ViewModel
        var contentView: UIView?
        var tableView: UITableViewController?
        var model: ViewModel?
        var subscription: AnyCancellable?
    }
}

// MARK: Navigation
extension DocumentView.ViewController {
    class NavigationBar: UINavigationBar {}
}

// MARK: Configuration
extension DocumentView.ViewController {
    func configured(_ model: ViewModel) -> Self {
        self.model = model
        self.subscription = self.model?.objectWillChange.sink(receiveValue: { (value) in
            self.tableView?.tableView.reloadData()
        })
        return self
    }
}

// MARK: Setup
extension DocumentView.ViewController {
    func setupUI() {
        self.setupElements()
        self.setupTableView()
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
//        tableView.tableView.delegate = self
        if let view = tableView.view {
            self.contentView?.addSubview(view)
        }
        tableView.tableView.estimatedRowHeight = 60
        tableView.tableView.rowHeight = UITableView.automaticDimension
        tableView.tableView.sectionHeaderHeight = 0
        tableView.tableView.separatorStyle = .none
        tableView.tableView.allowsSelection = false
        
        // register cells.
        tableView.tableView.register(Cell.self, forCellReuseIdentifier: Cell.cellReuseIdentifier())
        
        self.tableView = tableView
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

// MARK: View lifecycle
extension DocumentView.ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.viewWillAppear(animated)
    }
}

// MARK: UITableViewDataSource
extension DocumentView.ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model?.countOfElements(at: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = self.model?.element(at: indexPath) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: Cell.cellReuseIdentifier(), for: indexPath) as? Cell {
                cell.configured(item)
                return cell
            }
        }
        return .init()
    }
}

// MARK: Cell
extension DocumentView.ViewController {
    class Cell: UITableViewCell {
        var model: BlockViewBuilderProtocol?
        var containedView: UIView?
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        func setup() {
            self.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

// MARK: Configured
extension DocumentView.ViewController.Cell {
    class ViewBuilder {
        class func createView(_ model: BlockViewBuilderProtocol?) -> UIView? {
            guard let model = model else { return nil }
            let controller = UIHostingController(rootView: model.buildView())
            let view = controller.view
            return view
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        // put into container
        if let view = ViewBuilder.createView(self.model) {
            self.containedView?.removeFromSuperview()
            self.containedView = view
            self.contentView.addSubview(view)
            if let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
                view.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }
    func updateIfNewModel(_ model: BlockViewBuilderProtocol) {
        if model.id != self.model?.id {
            self.model = model
            self.prepareForReuse()
        }
    }
    func configured(_ model: BlockViewBuilderProtocol) -> Self {
        self.updateIfNewModel(model)
        return self
    }
}

// MARK: TableViewModelProtocol
extension DocumentView.ViewModel: TableViewModelProtocol {
    func numberOfSections() -> Int {
        1
    }
    
    func countOfElements(at: Int) -> Int {
        self.builders.count
    }
    
    func section(at: Int) -> DocumentView.ViewModel.Section {
        .init()
    }
    
    func element(at: IndexPath) -> DocumentView.ViewModel.Row {
        guard self.builders.indices.contains(at.row) else {
            return TextBlocksViews.Base.BlockViewModel.empty
        }
        return self.builders[at.row]
    }
    
    struct Section {}
    typealias Row = BlockViewBuilderProtocol
}
