//
//  DeveloperOptions+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 07.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension DeveloperOptions {
    class ViewModel {
        // to show we need settings at least.
        var service: Service?
        var settings: Settings
        var cells: [Cell] = []
        var updatedCells: [Cell] = []
        init(settings: Settings) {
            self.settings = settings
            let (_, entries) = SettingsSerialization.plaintify(settings: settings)
            self.cells = entries.map{ (item) in
                var cell = Cell(keypath: item.keypath)
                cell.title = item.title
                if let theValue = item.value {
                    switch theValue {
                    case .bool(let value): cell.value = .bool(value)
                    case .int(let value): cell.value = .int(value)
                    case .string(let value): cell.value = .string(value)
                    }
                }
                return cell
            }.sorted { $0.keypath < $1.keypath }
            self.updatedCells = self.cells
        }
        //        class ChildViewModel {
        //            weak var parent: ViewModel?
        //            init(parent: ViewModel?) {
        //                self.parent = parent
        //            }
        //        }
    }
}

extension DeveloperOptions.ViewModel {
    struct Cell {
        enum Value {
            case bool(Bool)
            case int(Int)
            case string(String)
            init?(value: AnyObject) {
                switch value {
                case let v as Bool: self = .bool(v)
                case let v as Int: self = .int(v)
                case let v as String: self = .string(v)
                default: return nil
                }
            }
//            func equal(value: Value) -> Bool {
//                switch self {
//                case .bool(let value): return false
//                case .int(let value): return false
//                case .string(let value): return false
//                }
//            }
        }
        
        mutating func update(value: Value) {
            self.value = value
        }
        
        var title: String?
        var value: Value?
        
        var keypath: String
        init(keypath: String) {
            self.keypath = keypath
        }
    }
}

// MARK: TableViewModelProtocol
protocol TableViewModelProtocol {
    associatedtype Section
    associatedtype Row
    func numberOfSections() -> Int
    func countOfElements(at: Int) -> Int
    func section(at: Int) -> Section
    func element(at: IndexPath) -> Row
}

extension DeveloperOptions.ViewModel: TableViewModelProtocol {
    struct Section {
        var title: String?
    }
    struct Row {
        enum CellType {
            case `switch`(Bool)
            case number(Int)
            case string(String)
            init?(value: Cell.Value?) {
                guard let theValue = value else {
                    return nil
                }
                
                switch theValue {
                case .bool(let value): self = .switch(value)
                case .int(let value): self = .number(value)
                case .string(let value): self = .string(value)
                }
            }
        }
        
        var resource: Cell?
        var type: CellType?
    }
    func numberOfSections() -> Int {
        return 1
    }
    
    func countOfElements(at: Int) -> Int {
        return self.cells.count
    }
    
    func section(at: Int) -> Section {
        return Section()
    }
    
    func element(at: IndexPath) -> Row {
        let cell = self.cells[at.row]
        guard let type = Row.CellType(value: cell.value) else {
            return Row()
        }
        
        return Row(resource: cell, type: type)
    }
}

// MARK: Save
extension DeveloperOptions.ViewModel {
    typealias Service = DeveloperOptions.Service
    typealias SettingsSerialization = DeveloperOptions.SettingsSerialization
    typealias Entry = SettingsSerialization.Entry
    func updated(value: Cell.Value, with identifier: String?) {
        let index = self.updatedCells.firstIndex { (cell) -> Bool in
            return cell.keypath == identifier
        }
        
        guard let theIndex = index else {
            return
        }
        self.updatedCells[theIndex].update(value: value)
    }
    
    func updated(value: Cell.Value, at indexPath: IndexPath) {
        self.updatedCells[indexPath.row].value = value
    }
    
    func save() {
        // call save?
        let entries = self.updatedCells.map { (from) -> Entry in
            var to = Entry(keypath: from.keypath)
            to.title = from.title
            if let theValue = from.value {
                switch theValue {
                case .bool(let value): to.value = .bool(value)
                case .int(let value): to.value = .int(value)
                case .string(let value): to.value = .string(value)
                }
            }
            return to
        }
        
        let settings = SettingsSerialization.immerse(entries: entries, into: self.settings)
        self.service?.update(settings: settings)
    }
}

// MARK: Configuration
extension DeveloperOptions.ViewModel {
    func configured(service: Service?) -> Self {
        self.service = service
        return self
    }
}
