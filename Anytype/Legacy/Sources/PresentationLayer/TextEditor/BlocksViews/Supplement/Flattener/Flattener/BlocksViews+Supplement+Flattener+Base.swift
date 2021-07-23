//
//  BlocksViews+Supplement+Flattener+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 24.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.Supplement

private extension Logging.Categories {
  static let blocksFlattener: Self = "Presentation.TextEditor.BlocksViews.Supplement.BlocksFlattener"
}

extension Namespace {
    /// Generic interface for classes that provides following transform:
    /// (TreeModel) -> Array<ViewModel>
    class BaseFlattener {
        /// Typealiases
        typealias Model = BlockActiveRecordModelProtocol
        typealias Information = BlockInformationModelProtocol
        typealias ResultViewModel = BlockViewBuilderProtocol
        /// Variables
        
        /// Keep it for a while.
        /// Maybe, we will inject every flattener with `CompoundFlattener`.
        fileprivate weak var router: BaseFlattener?
        
        /// Use it if you want to skip blocks.
        weak var unknownCaseRouter: BaseFlattener?
        
        fileprivate weak var container: TopLevelContainerModelProtocol?
        
        func getContainer() -> TopLevelContainerModelProtocol? {
            self.container
        }
        
        /// Methods
        
        /// Convert tree model to list of ViewModels.
        /// NOTE: Do not override this method in subclasses.
        /// Subclass: NO.
        ///
        /// - Parameter model: Tree model that we want to convert.
        /// - Returns: A list of ViewModels.
        ///
        public func toList(_ model: Model) -> [ResultViewModel] {
            self.toList([model])
        }
        
        /// Convert a list of models (children) to list of ViewModels.
        /// NOTE: Do not override this method in subclasses.
        /// Subclass: NO.
        /// - Parameter models: A list of models that we want to convert.
        /// - Returns: A list of ViewModels.
        func toList(_ models: [Model]) -> [ResultViewModel] {
            self.convert(children: models)
        }
        
        /// Find correct flattener for current model.
        /// We have different types of models ( blocks ), so, their needs are served by different Flatteners.
        /// NOTE: Override in Compound subclasses where you want to split functionality across subflatteners.
        /// Subclass: Possible for Compound Flatteners.
        ///
        /// - Parameter model: Model for which we would like to find a match.
        /// - Returns: Flattener that is matched this model and could flatten it.
        ///
        func match(_ model: Model) -> BaseFlattener? {
            nil
        }
        
        /// Convert tree model to a list of ViewModels.
        /// NOTE: It is the first method that you need to override.
        /// Subclass: YES.
        ///
        /// - Parameter model: Model that we would like to flatten.
        /// - Returns: List of Builders ( actually, view models ) that describes input model in terms of list.
        ///
        func convert(model: Model) -> [ResultViewModel] {
            self.match(model)?.convert(model: model) ?? []
        }

        /// Generic method which convert a list of chilren to view models.
        /// NOTE: If you can't reach what you want, override this method.
        /// Subclass: NO.
        ///
        /// - Parameter model: The parent model.
        /// - Parameter children: List of models that we would like to flatten.
        /// - Returns: List of Builders ( actually, view models ) that describes input model in terms of list.
        ///
        private func convert(children: [Model]) -> [ResultViewModel] {
            let grouped = DataStructures.GroupBy.group(children, by: {$0.blockModel.information.content.deepKind == $1.blockModel.information.content.deepKind})
            return grouped.flatMap({self.convert(child: $0.first, children: $0)})
        }
        
        /// NOTE:
        /// Not sure if it worked for nested lists.
        /// Possibly, no.
        ///
        /// This method helps you convert a group of blocks with the same type. ( type + contentType if exists ).
        /// It uses `match` method, so, you must know that at some point of conversion it should return non-nil.
        /// OR
        /// `nil` value is intended.
        /// Subclass: NO.
        ///
        /// - Parameters:
        ///   - child: Actually, the first object of children.
        ///   - children: A list of models that we would like to convert to ViewModels. Actually, they are of the same type ( deep kind ). (type + contentType if exists).
        /// - Returns: A list of ViewModels
        private func convert(child: Model?, children: [Model]) -> [ResultViewModel] {
            guard let child = child else { return [] }
            if let matched = self.match(child) {
                return matched.convert(child: child, children: children)
            }
            if let matched = self.router?.match(child) {
                return matched.convert(child: child, children: children)
            }
            return []
        }
                
        /// This method is the first point of overriding if you want to convert a list of models with the same type ( deep kind ) (type + contentType if exists.)
        ///
        /// It uses `convert(model:)` as default implementation.
        ///
        /// - Parameters:
        ///   - child: Actually, the first object of children.
        ///   - children: A list of models that we would like to convert to ViewModels. Actually, they are of the same type ( deep kind ). (type + contentType if exists).
        /// - Returns: A list of ViewModels.
        func convert(child: Model, children: [Model]) -> [ResultViewModel] {
            children.flatMap(self.convert(model:))
        }
                        
        /// Methods / Configurations
        func configured(_ container: TopLevelContainerModelProtocol?) -> Self {
            self.container = container
            return self
        }
        
        // MARK: - Initialization
        init() {}
    }
}

// MARK: - BaseFlattener / Childrens
extension Namespace.BaseFlattener {
    func processChildrenToList(_ model: Model) -> [ResultViewModel] {
        self.toList(model.childrenIds().compactMap(model.findChild(by:)))
    }
}

// MARK: BlocksFlattener
extension Namespace {
    /// Blocks flattener is compound flattener.
    /// It chooses correct flattener based on model type.
    class CompoundFlattener: BaseFlattener {
        var pageBlocksFlattener: PageBlocksFlattener = .init()
        var toolsFlattener: Tools.Flattener = .init()
        var textFlattener: Text.Flattener = .init()
        var fileFlattener: File.Flattener = .init()
        var bookmarkFlattener: Bookmark.Flattener = .init()
        var otherFlattener: Other.Flattener = .init()
        var layoutFlattener: LayoutBlocksFlattener = .init()
        var unknownBlocksFlattener: UnknownBlocksFlattener = .init()
        
        override func match(_ model: Model) -> BaseFlattener? {
            let kind = model.blockModel.kind
            switch kind {
            case .meta: return self.pageBlocksFlattener
            case .block:
                let content = model.blockModel.information.content
                switch content {
                case let .link(value) where [.page, .archive].contains(value.style): return self.toolsFlattener
                case .text: return self.textFlattener
                case .file: return self.fileFlattener
                case .bookmark: return self.bookmarkFlattener
                case .divider: return self.otherFlattener
                case .layout: return self.layoutFlattener
                default:
                    let logger = Logging.createLogger(category: .blocksFlattener)
                    os_log(.debug, log: logger, "We handle only content above. This Content (%@) isn't handled.", String(describing: content))
                    return self.unknownBlocksFlattener
                }
            }
        }
        
        override init() {
            super.init()
            [self.pageBlocksFlattener, self.toolsFlattener, self.textFlattener, self.fileFlattener, self.bookmarkFlattener, self.otherFlattener, self.layoutFlattener, self.unknownBlocksFlattener].forEach { (value) in
                value.router = self
            }
            self.textFlattener.unknownCaseRouter = self.unknownBlocksFlattener
        }
        
        /// Inject TopLevelContainerModelProtocol into Tools flattener.
        /// This flattener will inject `containers's` details into view model.
        override func configured(_ container: TopLevelContainerModelProtocol?) -> Self {
            _ = super.configured(container)
            _ = self.toolsFlattener.configured(container)
            return self
        }
    }
}

// MARK: PageBlocksFlattener
extension Namespace {
    // Could also parse meta blocks.
    class PageBlocksFlattener: BaseFlattener {
        override func convert(model: Model) -> [ResultViewModel] {
            switch model.blockModel.kind {
            case .meta: return self.router?.processChildrenToList(model) ?? []
            default: return self.router?.toList(model) ?? []
            }
        }
    }
}

// MARK: LayoutBlocksFlattener
extension Namespace {
    class LayoutBlocksFlattener: BaseFlattener {
        override func convert(model: Model) -> [ResultViewModel] {
            let blockModel = model.blockModel
            switch blockModel.kind {
            case .meta: return self.router?.toList(model) ?? []
            case .block:
                switch blockModel.information.content {
                case .layout: return self.router?.processChildrenToList(model) ?? []
                default: return self.router?.toList(model) ?? []
                }
            }
        }
    }
}

// MARK: UnknownBlocksFlattener
extension Namespace {
    class UnknownBlocksFlattener: BaseFlattener {
        override func convert(model: Model) -> [ResultViewModel] {
            [BlocksViews.New.Unknown.Label.ViewModel.init(model)] + self.processChildrenToList(model)
        }
    }
}

// MARK: Class methods
extension Namespace.BaseFlattener {
    static func compoundFlattener() -> BlocksViews.Supplement.BaseFlattener {
        Namespace.CompoundFlattener.init()
    }
    static var defaultValue: BlocksViews.Supplement.BaseFlattener {
        self.compoundFlattener()
    }
}

// Rethink for a bit.
// For example, we could do the following:
//
// Every Flattener has child/parent relationship.
// And also Root flattener.
// When we see a model, we could either:
// 1. Move to a new flattener.
// 2. Continue with over flattener.
// 3. Move backwards to our parent flattener.
// 4. Ask a root about appropriate flattener.
// 5. We could keep a stack of flatteners, for example.
// Current implementation is:
// 1. Compound flattener is a "Router" of flatteners.
// 2. Every router has a link to Compound flattener to handle unknown blocks.
// 3. Also we should have "Unknown block" flattener.

