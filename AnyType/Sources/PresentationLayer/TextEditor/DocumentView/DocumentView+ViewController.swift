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

        @Environment(\.developerOptions) var developerOptions

        var contentView: UIView?
        var tableView: UITableViewController?
        
        var dataSource: UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Row>?
        
        var model: ViewModel?
        
        var modelUpdateSubscription: AnyCancellable?
        var modelAnyFieldUpdateSubscription: AnyCancellable?
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
        self.modelUpdateSubscription = self.model?.$buildersRows.sink(receiveValue: { (value) in
            // we should calculate
            print("some builders count: \(value.count)")
            self.updateData(value)
        })
        self.modelAnyFieldUpdateSubscription = self.model?.anyFieldUpdateSubject.sink(receiveValue: { [weak self] (value) in
            print("this is text: \(value)")
            self?.updateView()
        })
        return self
    }
}

// MARK: Setup
extension DocumentView.ViewController {
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
    
    func setupDataSource() {
        if let tableView = self.tableView?.tableView {
            self.dataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Row>.init(tableView: tableView, cellProvider: { (tableView, indexPath, entry) -> UITableViewCell? in
                let useUIKit = !self.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldEmbedSwiftUIIntoCell
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: Cell.cellReuseIdentifier(), for: indexPath) as? Cell {
                    _ = cell.configured(useUIKit: useUIKit).configured(entry)
                    return cell
                }
                return UITableViewCell.init()
                
//                if self.developerOptions.current.workflow.mainDocumentEditor.textEditor.shouldEmbedSwiftUIIntoCell {
//                    let doctorView = DoctorCell.init().configured { [weak self] cell in
//                        (cell as? DoctorCell)?.containedView.flatMap{$0.setNeedsUpdateConstraints()}
//                        cell.setNeedsUpdateConstraints()
//                        cell.setNeedsLayout()
//                        DispatchQueue.main.async {
//                            self?.tableView?.tableView.beginUpdates()
//                            self?.tableView?.tableView.endUpdates()
//                        }
//                    }.configured(entry)
//                    return doctorView
//                }
//                else {
//                    let emptyView = EmptyCell.init().configured {
//                        [weak self] in
//                        self?.tableView?.tableView.beginUpdates()
//                        self?.tableView?.tableView.endUpdates()
//                    }
//                    if indexPath.row == 1 {
//                        emptyView.textView.backgroundColor = .green
//                    }
//                    return emptyView
//                }
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

// MARK: Initial Update data
extension DocumentView.ViewController {
    func updateView() {
        DispatchQueue.main.async {
            self.tableView?.tableView.beginUpdates()
            self.tableView?.tableView.endUpdates()
        }
    }
    func updateData(_ rows: [ViewModel.Row]) {
        guard let model = self.model, let dataSource = self.dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.deleteSections([ViewModel.Section.first])
        snapshot.appendSections([ViewModel.Section.first])
        snapshot.appendItems(rows)
        print("number of objects: \(rows.count)")
        dataSource.apply(snapshot)
    }
}

// MARK: View lifecycle
extension DocumentView.ViewController {
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
        typealias Model = DocumentView.ViewModel.Row
        
        var model: Model?
        var containedView: UIView?
        var useUIKit: Bool = false
        
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
        class func createView(_ model: BlockViewBuilderProtocol?, useUIKit: Bool) -> UIView? {
            guard let model = model else { return nil }
            if useUIKit {
                return model.buildUIView()
            }
            let controller = UIHostingController(rootView: model.buildView())
            let view = controller.view
            return view
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        // put into container
        if let view = ViewBuilder.createView(self.model?.builder, useUIKit: self.useUIKit) {
            self.containedView?.removeFromSuperview()
            self.containedView = view
            self.contentView.addSubview(view)
            if let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
                view.translatesAutoresizingMaskIntoConstraints = false
                view.clipsToBounds = true
            }
        }
    }
    func updateIfNewModel(_ model: Model) {
        if model != self.model {
            self.model = model
            self.prepareForReuse()
        }
    }
    func configured(_ model: Model) -> Self {
        self.updateIfNewModel(model)
        return self
    }
    func configured(useUIKit: Bool) -> Self {
        self.useUIKit = useUIKit
        return self
    }
}

// MARK: EmptyCell
extension DocumentView.ViewController {
    class EmptyCell: UITableViewCell, UITextViewDelegate {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        
        func configured(_ changed: @escaping () -> ()) -> Self {
            self.textChanged = changed
            return self
        }
        
        var textChanged: () -> () = { }
        var textView: UITextView!
        
        func setup() {
            self.translatesAutoresizingMaskIntoConstraints = false
            let view: UITextView = {
                let view = UITextView()
                view.font = .preferredFont(forTextStyle: .body)
                view.textContainer.lineFragmentPadding = 0.0
                view.textContainerInset = .zero
                view.isScrollEnabled = false
                view.delegate = self
                return view
            }()
            self.contentView.addSubview(view)
            
            if let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
                view.translatesAutoresizingMaskIntoConstraints = false
            }
            self.textView = view
        }
        func textViewDidChange(_ textView: UITextView) {
            UIView.outputSubviews(self.contentView)
            self.textChanged()
        }
    }
}

extension UIView {
    static func outputSubviews(_ view: UIView) {
        print(self.readSubviews(view))
    }
    static func readSubviews(_ view: UIView) -> [(String, CGRect)] {
        [(String(reflecting: type(of: view)), view.frame)] + view.subviews.flatMap(readSubviews)
    }
}

// MARK: DoctorCell
extension DocumentView.ViewController {
    class DoctorCell: UITableViewCell, TextBlocksViewsUserInteractionProtocol {
        func didReceiveAction(block: Block, id: Block.ID, action: TextView.UserAction) {
            didReceiveAction(action)
        }
        
        func didReceiveAction(_ action: TextView.UserAction) {
            switch action {
            case let .inputAction(input):
                switch input {
                case let .changeText(text):
                    self.setNeedsLayout()
                    UIView.outputSubviews(self.contentView)
                    self.textChanged(self)
                default: return
                }
            default: return
            }
        }

        typealias Model = DocumentView.ViewModel.Row

        var model: Model?
        var containedView: UIView?
        
        func configured(_ changed: @escaping (UITableViewCell) -> ()) -> Self {
            self.textChanged = changed
            return self
        }
        
        var textChanged: (UITableViewCell) -> () = {_ in }
        
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
            if let view = ViewBuilder.createView(self.model?.builder) {
                self.containedView?.removeFromSuperview()
                self.containedView = view
                self.contentView.addSubview(view)
                if let superview = view.superview {
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                    view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.clipsToBounds = true
                }
            }
        }
        func updateIfNewModel(_ model: Model) {
            if model != self.model {
                (model.builder as? TextBlocksViewsUserInteractionProtocolHolder)?.configured(self)
                self.model = model
                self.prepareForReuse()
            }
        }
        func configured(_ model: Model) -> Self {
            self.updateIfNewModel(model)
            return self
        }
    }
}
