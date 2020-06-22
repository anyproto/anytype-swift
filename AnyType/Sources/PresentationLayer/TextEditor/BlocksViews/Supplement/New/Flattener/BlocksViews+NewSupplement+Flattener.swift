//
//  BlocksViews+Supplement.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 24.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
  static let blocksFlattener: Self = "Presentation.TextEditor.BlocksViews.Supplement.BlocksFlattener"
}

extension BlocksViews.NewSupplement {
    /// Generic interface for classes that provides following transform:
    /// (TreeModel) -> Array<ViewModel>
    class BaseFlattener {
        typealias Model = BlocksModelsChosenBlockModelProtocol
        typealias Information = BlocksModelsInformationModelProtocol

        
        /// Convert tree model to list of ViewModels.
        /// NOTE: Do not override this method in subclasses.
        /// Subclass: NO.
        ///
        /// - Parameter model: Tree model that we want to convert.
        /// - Returns: List of ViewModels.
        ///
        public func toList(_ model: Model) -> [BlockViewBuilderProtocol] {
            self.convert(model: model)
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
        /// Subclass: YES.
        ///
        /// - Parameter children: List of models that we would like to flatten.
        /// - Returns: List of Builders ( actually, view models ) that describes input model in terms of list.
        ///
        func convert(children: [Model]) -> [BlockViewBuilderProtocol] {
            let grouped = DataStructures.GroupBy.group(children, by: {$0.blockModel.information.content.kind == $1.blockModel.information.content.kind})
            
            return []
        }
    }
}

// MARK: BlocksFlattener
extension BlocksViews.NewSupplement {
    /// Blocks flattener is compound flattener.
    /// It chooses correct flattener based on model type.
    class BlocksFlattener: BaseFlattener {
        /// WARNING! Prevents Inheritance cyclic initialization.
        /// Do not remove `lazy`.
        lazy var pageBlocksFlattener: PageBlocksFlattener = .init()
        var toolsFlattener: Tools.Flattener = .init()
        var textFlattener: Text.Flattener = .init()
        var fileFlattener: File.Flattener = .init()
        
        override func match(_ model: Model) -> BaseFlattener? {
            let kind = model.blockModel.kind
            switch kind {
            case .meta: return self.pageBlocksFlattener
            case .block:
                let content = model.blockModel.information.content
                switch content {
                case let .link(value) where value.style == .page: return self.toolsFlattener
                case .text: return self.textFlattener
                case .file: return self.fileFlattener
                default:
                    let logger = Logging.createLogger(category: .blocksFlattener)
                    os_log(.debug, log: logger, "We handle only content above. This Content (%@) isn't handled.", String(describing: content))
                    return nil
                }
            }
        }
    }
}

// MARK: PageBlocksFlattener
extension BlocksViews.NewSupplement {
    // Could also parse meta blocks.
    class PageBlocksFlattener: BlocksFlattener {
        override func convert(model: BlocksViews.NewSupplement.BaseFlattener.Model) -> [BlockViewBuilderProtocol] {
            switch model.blockModel.kind {
            case .meta: return model.childrenIds().compactMap(model.findChild(by:)).flatMap(self.toList)
            default: return super.convert(model: model)
            }
        }
    }
}
