//
//  DocumentViewModel+New+RowsAndSections.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import BlocksModels

fileprivate typealias Namespace = DocumentModule

// MARK: - TableViewModelProtocol
extension Namespace.DocumentViewModel: TableViewModelProtocol {
    func numberOfSections() -> Int {
        1
    }
    
    func countOfElements(at: Int) -> Int {
        self.builders.count
    }
    
    func section(at: Int) -> Section {
        .init()
    }
    
    func element(at: IndexPath) -> Row {
        guard self.builders.indices.contains(at.row) else {
            fatalError("Row doesn't exist")
        }
        var row = Row.init(builder: self.builders[at.row])
        _ = row.configured(selectionHandler: self.selectionHandler)
        return row
    }
    
    struct Section {
        var section: Int = 0
        static var first: Section = .init()
        init() {}
    }
    
    struct Row {
        /// Soo.... We can't keep model in it.
        /// We should add information as structure ( which is immutable )
        /// And use it as presentation structure for cell.
        weak var builder: BlockViewBuilderProtocol?
        weak var selectionHandler: DocumentModuleSelectionHandlerCellProtocol?
        var information: BlockInformationModelProtocol?
        init(builder: BlockViewBuilderProtocol?) {
            self.builder = builder
            self.information = (self.builder as? BlocksViewsNamespace.Base.ViewModel)?.getBlock().blockModel.information
        }
        
        /// Pretty full-typed builder accessor
        var blockBuilder: BlocksViews.New.Base.ViewModel? {
            self.builder as? BlocksViewsNamespace.Base.ViewModel
        }
        
        /// CachedDiffable. Check if user session for this cell has changed.
        /// It is only for UI states.
        struct CachedDiffable: Hashable {
            var selected: Bool = false
            mutating func set(selected: Bool) {
                self.selected = selected
            }
        }
        
        var cachedDiffable: CachedDiffable = .init()
        func sameCachedDiffable(_ other: Self?) -> Bool {
            self.cachedDiffable != other?.cachedDiffable
        }
        
        mutating func update(cachedDiffable: CachedDiffable) {
            self.cachedDiffable = cachedDiffable
        }
        
        /// First Responder manipulations for Text Cells.
        var isPendingFirstResponder: Bool {
            self.blockBuilder?.getBlock().isFirstResponder ?? false
        }
        func resolvePendingFirstResponder() {
            if let model = self.blockBuilder?.getBlock() {
                TopLevel.AliasesMap.BlockUtilities.FirstResponderResolver.resolvePendingUpdate(model)
            }
        }
    }
}

// MARK: - TableViewModelProtocol.Row / Configurations
extension Namespace.DocumentViewModel.Row {
    mutating func configured(selectionHandler: DocumentModuleSelectionHandlerCellProtocol?) -> Self {
        self.selectionHandler = selectionHandler
        self.cachedDiffable = .init(selected: self.isSelected)
        return self
    }
}

// MARK: - TableViewModelProtocol.Row / Indentation level
extension Namespace.DocumentViewModel.Row {
    typealias BlocksViewsNamespace = BlocksViews.New
    var indentationLevel: UInt {
        (self.builder as? BlocksViewsNamespace.Base.ViewModel).flatMap({$0.indentationLevel()}) ?? 0
    }
}

// MARK: - TableViewModelProtocol.Row / Rebuilding and Diffable
extension Namespace.DocumentViewModel.Row {
    func rebuilded() -> Self {
        .init(builder: self.builder)
    }
    func diffable() -> AnyHashable? {
//        if let builder = self.builder as? BlocksViewsNamespace.Base.ViewModel {
//            let diffable = self.information?.diffable()
//            let allEntries = [
//                "isFirstResponder": builder.getBlock().isFirstResponder,
//                "informationDiffable": diffable
//            ]
//            return .init(allEntries)
//        }
        return self.information?.diffable()
    }
}

// MARK: - TableViewModelProtocol.Row / Selection
extension Namespace.DocumentViewModel.Row: DocumentModuleSelectionCellProtocol {
    func getSelectionKey() -> BlockId? {
        (self.builder as? BlocksViewsNamespace.Base.ViewModel)?.getBlock().blockModel.information.id
    }
}


// MARK: - TableViewModelProtocol.Section
extension Namespace.DocumentViewModel.Section: Hashable {}

// MARK: - TableViewModelProtocol.Row

/// Well, we could compare buildersRows by their diffables...
/// But for now it is fine for us to keep simple equations.
///
/// NOTES: Why we could compare `diffables`.
/// As soon as we use `Row` as `DataModel` for a `shared` view model `builder`
/// we should keep a track of `initial` state of Rows.
/// We do it by providing `information` propepty, which is initiated in `init()`.
/// Treat this property as `fingerprint` of `initial` builder value.
///
///
extension Namespace.DocumentViewModel.Row: Hashable, Equatable {
    static private func sameKind(_ lhs: Self?, _ rhs: Self?) -> Bool {
        lhs?.information?.content.deepKind == rhs?.information?.content.deepKind
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.builder?.blockId == rhs.builder?.blockId && lhs.cachedDiffable == rhs.cachedDiffable && sameKind(lhs, rhs)
//        lhs.diffable() == rhs.diffable() && lhs.cachedDiffable == rhs.cachedDiffable
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.builder?.blockId ?? "")
//        hasher.combine(self.diffable())
    }
}
