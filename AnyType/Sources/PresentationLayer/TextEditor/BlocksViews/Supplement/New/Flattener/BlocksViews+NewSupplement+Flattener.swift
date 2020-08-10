//
//  BlocksViews+Supplement.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 24.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.NewSupplement

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

        /// Variables
        
        /// Keep it for a while.
        /// Maybe, we will inject every flattener with `CompoundFlattener`.
        fileprivate weak var router: BaseFlattener?
        
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
        public func toList(_ model: Model) -> [BlockViewBuilderProtocol] {
            self.toList([model])
        }
        
        /// Convert a list of models (children) to list of ViewModels.
        /// NOTE: Do not override this method in subclasses.
        /// Subclass: NO.
        /// - Parameter models: A list of models that we want to convert.
        /// - Returns: A list of ViewModels.
        func toList(_ models: [Model]) -> [BlockViewBuilderProtocol] {
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
        func convert(model: Model) -> [BlockViewBuilderProtocol] {
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
        private func convert(children: [Model]) -> [BlockViewBuilderProtocol] {
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
        private func convert(child: Model?, children: [Model]) -> [BlockViewBuilderProtocol] {
            guard let child = child, let matched = self.match(child) else {
                return []
            }
            return matched.convert(child: child, children: children)
        }
                
        /// This method is the first point of overriding if you want to convert a list of models with the same type ( deep kind ) (type + contentType if exists.)
        ///
        /// It uses `convert(model:)` as default implementation.
        ///
        /// - Parameters:
        ///   - child: Actually, the first object of children.
        ///   - children: A list of models that we would like to convert to ViewModels. Actually, they are of the same type ( deep kind ). (type + contentType if exists).
        /// - Returns: A list of ViewModels.
        func convert(child: Model, children: [Model]) -> [BlockViewBuilderProtocol] {
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
    func processChildrenToList(_ model: Model) -> [BlockViewBuilderProtocol] {
        self.toList(model.childrenIds().compactMap(model.findChild(by:)))
    }
}

// MARK: BlocksFlattener
extension Namespace {
    /// Blocks flattener is compound flattener.
    /// It chooses correct flattener based on model type.
    class CompoundFlattener: BaseFlattener {
        var pageBlocksFlattener: PageBlocksFlattener?
        var toolsFlattener: Tools.Flattener = .init()
        var textFlattener: Text.Flattener = .init()
        var fileFlattener: File.Flattener = .init()
        var bookmarkFlattener: Bookmark.Flattener = .init()
        var otherFlattener: Other.Flattener = .init()
        
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
                default:
                    let logger = Logging.createLogger(category: .blocksFlattener)
                    os_log(.debug, log: logger, "We handle only content above. This Content (%@) isn't handled.", String(describing: content))
                    return nil
                }
            }
        }
        
        override init() {
            super.init()
            self.pageBlocksFlattener = .init(self)
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
        unowned var delegateFlattener: BaseFlattener
        override func convert(model: BlocksViews.NewSupplement.BaseFlattener.Model) -> [BlockViewBuilderProtocol] {
            switch model.blockModel.kind {
            case .meta: return self.delegateFlattener.processChildrenToList(model)
            default: return self.delegateFlattener.toList(model)
            }
        }
        init(_ blocksFlattener: BaseFlattener) {
            self.delegateFlattener = blocksFlattener
        }
    }
}
