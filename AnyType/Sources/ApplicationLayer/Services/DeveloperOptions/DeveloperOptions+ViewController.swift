//
//  DeveloperOptions+ViewController.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 07.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

extension DeveloperOptions {
    class ViewController: UIViewController {
        var contentView: UIView?
        var tableView: UITableViewController?
        var model: ViewModel?
    }
}

// MARK: Navigation
extension DeveloperOptions.ViewController {
    class NavigationBar: UINavigationBar {}    
}

// MARK: Setup
extension DeveloperOptions.ViewController {
    func setupUI() {
        self.setupElements()
        self.setupTableView()
        self.setupNavigation()
        self.addLayout()
    }
    
    func setupNavigation() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(reactOnSaveDidPressed))
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
        
        // register cells.
        //        tableView.tableView.register(CartItemTableViewCell.nib(), forCellReuseIdentifier: CartItemTableViewCell.cellReuseIdentifier())
        tableView.tableView.register(CellWithSwitch.self, forCellReuseIdentifier: CellWithSwitch.cellReuseIdentifier())
        tableView.tableView.register(CellWithTextField.self, forCellReuseIdentifier: CellWithTextField.cellReuseIdentifier())
        
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
extension DeveloperOptions.ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.viewWillAppear(animated)
    }
}

// MARK: Reactions
extension DeveloperOptions.ViewController {
    @objc func reactOnSaveDidPressed() {
        self.model?.save()
    }
}

// MARK: HasModelProtocol
//extension DeveloperOptions.ViewController: HasModelProtocol {
//    func updateForNewModel() {
//        _ = self.model?.cells
//    }
//}

extension DeveloperOptions.ViewController {
    typealias ViewModel = DeveloperOptions.ViewModel
    func configured(_ model: ViewModel) -> Self {
        self.model = model
        return self
    }
}

// MARK: UITableViewDataSource
extension DeveloperOptions.ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model?.countOfElements(at: section) ?? 0
    }
    
    //    func cell<T>(_ tableView: UITableView, for type: Developer.ViewModel.Row.CellType, cellType: T.Type, at: IndexPath) -> T? where T: UITableViewCell {
    //        switch type {
    //        case .switch: tableView.dequeueReusableCell(withIdentifier: T.cellReuseIdentifier(), for: at) as? T.Type
    //        case .number: tableView.dequeueReusableCell(withIdentifier: T.cellReuseIdentifier(), for: at) as? T.Type
    //        case .string: tableView.dequeueReusableCell(withIdentifier: T.cellReuseIdentifier(), for: at) as? T.Type
    //        default:
    //            return UITableViewCell() as? T
    //        }
    //    }
    
    //    func tableView(_ tableView: UITableView, item: Developer.ViewModel.Row, at: IndexPath) -> UITableViewCell? {
    //
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = self.model?.element(at: indexPath), let type = item.type {
            switch type {
            case .switch(let value):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellWithSwitch.cellReuseIdentifier(), for: indexPath) as? CellWithSwitch else {
                    return UITableViewCell()
                }
                cell.textLabel?.text = item.resource?.title
                cell.detailTextLabel?.text = item.resource?.keypath
                cell.switchControl?.setOn(value, animated: true)
                _ = cell.configured(delegate: self).configured(identifier: item.resource?.keypath).configured(cellType: type)
                return cell
            case .number(let value):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellWithTextField.cellReuseIdentifier(), for: indexPath) as? CellWithTextField else {
                    return UITableViewCell()
                }
                let theValue = "\(value)"
                cell.textLabel?.text = item.resource?.title
                cell.detailTextLabel?.text = item.resource?.keypath
                cell.updateTextField(text: theValue)
                _ = cell.configured(delegate: self).configured(identifier: item.resource?.keypath).configured(cellType: type)
                return cell
            case .string(let value):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: CellWithTextField.cellReuseIdentifier(), for: indexPath) as? CellWithTextField else {
                    return UITableViewCell()
                }
                cell.textLabel?.text = item.resource?.title
                cell.detailTextLabel?.text = item.resource?.keypath
                cell.updateTextField(text: value)
                _ = cell.configured(delegate: self).configured(identifier: item.resource?.keypath).configured(cellType: type)
                return cell
            }
        }
        return UITableViewCell()
    }
}

// MARK: UITableViewDelegate
extension DeveloperOptions.ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

protocol Developer_ViewModel_ViewController_CellsUpdateProtocol {
    func didUpdate(cell: DeveloperOptions.ViewController.CellWithItem, identifier: String?)
}

// MARK: Developer_ViewModel_ViewController_CellsUpdateProtocol
extension DeveloperOptions.ViewController: Developer_ViewModel_ViewController_CellsUpdateProtocol {
    func didUpdate(cell: CellWithItem, identifier: String?) {
        guard let theType = cell.cellType else {
            return
        }
        
        switch theType {
        case .switch(let value): self.model?.updated(value: .bool(value), with: cell.identifier)
        case .number(let value): self.model?.updated(value: .int(value), with: cell.identifier)
        case .string(let value): self.model?.updated(value: .string(value), with: cell.identifier)
        }
    }
}

// MARK: Cells
// MARK: Cells / BaseTableViewCell
extension UITableViewCell {
    class func cellReuseIdentifier() -> String { NSStringFromClass(self) }
}

class BaseTableViewCell: UITableViewCell {
    enum PrepareItems {
        case data
        case color
        case font
    }
    
    func prepareItems(items: PrepareItems) {}
    
    func prepareCell() {
        self.prepareItems(items: .data)
        self.prepareItems(items: .color)
        self.prepareItems(items: .font)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepareCell()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareCell()
    }
}

// MARK: Cells / CellWithItem
extension DeveloperOptions.ViewController {
    class CellWithItem: BaseTableViewCell {
        var delegate: Developer_ViewModel_ViewController_CellsUpdateProtocol?
        var cellType: DeveloperOptions.ViewModel.Row.CellType?
        var identifier: String?
        
        func configured(delegate: Developer_ViewModel_ViewController_CellsUpdateProtocol?) -> Self {
            self.delegate = delegate
            return self
        }
        
        func configured(identifier: String?) -> Self {
            self.identifier = identifier
            return self
        }
        
        func configured(cellType: DeveloperOptions.ViewModel.Row.CellType?) -> Self {
            self.cellType = cellType
            return self
        }
        
        func tellAboutUpdates() {
            self.delegate?.didUpdate(cell: self, identifier: self.identifier)
        }
        
        func setup() {
            
        }
        
        override func prepareItems(items: BaseTableViewCell.PrepareItems) {
            super.prepareItems(items: items)
            self.setup()
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
            self.setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.setup()
        }
    }
    
    class CellWithSwitch: CellWithItem {
        var switchControl: UISwitch? {
            return self.accessoryView as? UISwitch
        }
        override func setup() {
            self.accessoryView = UISwitch()
            self.switchControl?.addTarget(self, action: #selector(reactOnValueDidChanged), for: .valueChanged)
        }
        
        @objc func reactOnValueDidChanged() {
            guard let theType = self.cellType else {
                return
            }
            switch theType {
            case .switch(_): self.cellType = .switch(self.switchControl?.isOn ?? false)
            case .number(_): break
            case .string(_): break
            }
            self.tellAboutUpdates()
        }
    }
    
    class CellWithTextField: CellWithItem, UITextFieldDelegate {
        var textField: UITextField? {
            return self.accessoryView as? UITextField
        }
        override func setup() {
            self.accessoryView = UITextField()
            self.textField?.delegate = self
            self.textField?.textColor = UIColor.white
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            _ = self.textField?.invalidateIntrinsicContentSize()
        }
        func updateTextField(text: String?) {
            self.textField?.text = text
            self.textField?.sizeToFit()
            self.textField?.invalidateIntrinsicContentSize()
            self.textField?.layoutIfNeeded()
        }
        
        func reactOnValueDidChanged() {
            guard let theType = self.cellType else {
                return
            }
            
            let text = self.textField?.text ?? ""
            
            switch theType {
            case .switch(_): break
            case .number(_): self.cellType = .number(Int(text) ?? 0)
            case .string(_): self.cellType = .string(text)
            }
            
            self.tellAboutUpdates()
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            self.reactOnValueDidChanged()
            
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.reactOnValueDidChanged()
            return false
        }
    }
}

