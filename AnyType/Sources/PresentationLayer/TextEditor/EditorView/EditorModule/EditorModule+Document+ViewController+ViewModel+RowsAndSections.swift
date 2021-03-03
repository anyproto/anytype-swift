//
//  DocumentViewModel+New+RowsAndSections.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import BlocksModels

fileprivate typealias Namespace = EditorModule.Document.ViewController.ViewModel

// MARK: - TableViewModelProtocol

extension Namespace {
    
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
        weak var selectionHandler: EditorModuleSelectionHandlerCellProtocol?
        var information: BlockInformationModelProtocol?
        private var _diffable: AnyHashable?

        init(builder: BlockViewBuilderProtocol?) {
            self.builder = builder
            let blockBuilder = (self.builder as? BlocksViewsNamespace.Base.ViewModel)
            self.information = blockBuilder?.getBlock().blockModel.information
            self._diffable = blockBuilder?.makeDiffable()
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

// MARK: - Section Hashable

extension Namespace.Section: Hashable {}

// MARK: - Row / Configurations

extension Namespace.Row {
    mutating func configured(selectionHandler: EditorModuleSelectionHandlerCellProtocol?) -> Self {
        self.selectionHandler = selectionHandler
        self.cachedDiffable = .init(selected: self.isSelected)
        return self
    }
}

// MARK: - Row / Indentation level

extension Namespace.Row {
    typealias BlocksViewsNamespace = BlocksViews.New
    var indentationLevel: UInt {
        (self.builder as? BlocksViewsNamespace.Base.ViewModel).flatMap({$0.indentationLevel()}) ?? 0
    }
}

// MARK: - Row / Rebuilding and Diffable

extension Namespace.Row {
    func diffable() -> AnyHashable? {
        self.information?.diffable()
    }
}

// MARK: - Row / Selection

extension Namespace.Row: EditorModuleSelectionCellProtocol {
    func getSelectionKey() -> BlockId? {
        (self.builder as? BlocksViewsNamespace.Base.ViewModel)?.getBlock().blockModel.information.id
    }
}

// MARK: - Hashable

/// Well, we could compare buildersRows by their diffables...
/// But for now it is fine for us to keep simple equations.
///
/// NOTES: Why we could compare `diffables`.
/// As soon as we use `Row` as `DataModel` for a `shared` view model `builder`
/// we should keep a track of `initial` state of Rows.
/// We do it by providing `information` propepty, which is initiated in `init()`.
/// Treat this property as `fingerprint` of `initial` builder value.
extension Namespace.Row: Hashable, Equatable {
    static private func sameKind(_ lhs: Self?, _ rhs: Self?) -> Bool {
        lhs?.information?.content.deepKind == rhs?.information?.content.deepKind
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.cachedDiffable == rhs.cachedDiffable && lhs.blockBuilderDiffable() == rhs.blockBuilderDiffable()
    }
    
    func hash(into hasher: inout Hasher) {
        guard let diffable = self.blockBuilderDiffable() else { return }
        hasher.combine(diffable)
    }

    private func blockBuilderDiffable() -> AnyHashable? {
        self._diffable
    }
}
