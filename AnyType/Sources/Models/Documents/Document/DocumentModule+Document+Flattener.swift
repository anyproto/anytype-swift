//
//  DocumentModule+Document+Flattener.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.01.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import BlocksModels

fileprivate typealias Namespace = DocumentModule.Document
fileprivate typealias FileNamespace = Namespace.BaseFlattener

extension FileNamespace {
    struct Options {
        var shouldIncludeRootNode: Bool = false
        static var `default`: Self = .init()
    }
}

extension Namespace {
    ///
    /// # Abstract
    /// Algorithm is
    /// "Put on stack in backwards order."
    ///
    /// ## Why does it work?
    ///
    /// Consider that you have the following structure
    ///
    /// ```
    /// Input:
    /// A -> [B, C, D]
    ///
    /// B -> [X]
    /// C -> [Y]
    /// D -> [Z]
    /// ```
    ///
    /// ```
    /// Result: [A, B, X, C, Y, D, Z]
    /// ```
    ///
    /// It is like a left-order traversing of tree, but we have to output parents first.
    /// It is like a DFS, but again, we would like to output parents first.
    ///
    /// Our Solution:
    ///
    /// ```
    /// 1. Stack = Init
    /// 2. A -> Stack [A]
    /// 3. While NotEmpty(Stack)
    /// 3. Value <- Stack []
    /// 4. Value -> Solution (A)
    /// 5. Children(Value).Reversed -> Stack [B, C, D] /// Look carefully.
    /// 6. Repeat.
    /// ```
    ///
    class BaseFlattener {
        typealias ActiveModel = BlockActiveRecordModelProtocol
        fileprivate typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias Container = TopLevelContainerModelProtocol
        
        /// Returns flat list of nested data starting from model at root ( node ) and moving down through a list of its children.
        /// It is like a "opening all nested folders" in a parent folder.
        ///
        /// - Parameters:
        ///   - model: Model ( or Root ) from which we would like to start.
        ///   - container: A container in which we will find items.
        /// - Returns: A list of active models.
        private static func flatten(root model: ActiveModel, in container: Container) -> [ActiveModel] {
            var result: Array<BlockId> = .init()
            let stack: DataStructures.Stack<BlockId> = .init()
            let blocksContainer = container.blocksContainer
            stack.push(model.blockModel.information.id)
            while !stack.isEmpty {
                if let value = stack.pop() {
                    /// Various flatteners?
                    if self.shouldKeep(item: value, in: container) {
                        result.append(value)
                    }
                    
                    /// Do numbered stuff?
                    let children = self.filteredChildren(of: value, in: container)
                    self.preprocessingChildren(children, in: container)
                    for item in children.reversed() {
                        stack.push(item)
                    }
                }
            }
            return result.compactMap({blocksContainer.choose(by: $0)})
        }
                
        /// Returns flat list of nested data starting from model at root ( node ) and moving down through a list of its children.
        /// It is like a "opening all nested folders" in a parent folder.
        /// - Parameters:
        ///   - model: Model ( or Root ) from which we would like to start.
        ///   - container: A container in which we will find items.
        ///   - options: Options for flattening strategies.
        /// - Returns: A list of active models.
        static func flatten(root model: ActiveModel, in container: Container, options: Options) -> [ActiveModel] {
            /// TODO: Fix it.
            /// Because `ShouldKeep` template method will flush out all unnecessary blocks from list.
            /// There is no need to skip first block ( or parent block ) if it is already skipped by `ShouldKeep`.
            ///
            /// But for any other parent block it will work properly.
            ///
            let rootItemIsAlreadySkipped = !self.shouldKeep(item: model.blockModel.information.id, in: container)
            if options.shouldIncludeRootNode || rootItemIsAlreadySkipped {
                return self.flatten(root: model, in: container)
            }
            else {
                return Array(self.flatten(root: model, in: container).dropFirst())
            }
        }
    }
}

// MARK: - Helpers
private extension FileNamespace {
    /// Template method.
    /// If you would like to keep item in result list of blocks, you should return true.
    /// - Parameters:
    ///   - item: Id of current item.
    ///   - container: Container.
    /// - Returns: A condition if we would like to keep item in list.
    private static func shouldKeep(item: BlockId, in container: Container) -> Bool {
        guard let model = container.blocksContainer.choose(by: item) else {
            return false
        }
        switch model.blockModel.information.content {
        case let .layout(value) where value.style != .div: return false
        case .smartblock: return false
        default: return true
        }
    }
    
    
    /// Template method.
    /// If we would like to filter children somehow, we could do it here.
    /// - Parameters:
    ///   - item: Id of current item.
    ///   - container: Container.
    /// - Returns: Filtered children of an item.
    private static func filteredChildren(of item: BlockId, in container: Container) -> [BlockId] {
        guard let model = container.blocksContainer.choose(by: item) else {
            return []
        }
        switch model.blockModel.information.content {
        case let .text(value) where value.contentType == .toggle: return ToggleFlattener.processedChildren(item, in: container)
        default: return container.blocksContainer.children(of: item)
        }
    }
    
    /// Template method.
    /// Preprocess children of item. If you would like to change some things before rendering, it is the best place.
    /// - Parameters:
    ///   - children: Children ids.
    ///   - container: Container.
    private static func preprocessingChildren(_ children: [BlockId],  in container: Container) {
        NumberedFlattener.process(children, in: container)
    }
}

private extension FileNamespace {
    /// TODO:
    /// Add Toggle and Numbered Flatteners.
    ///
    class ToggleFlattener {
        static func processedChildren(_ id: BlockId, in container: Container) -> [BlockId] {
            let isToggled = container.blocksContainer.userSession.isToggled(by: id)
            if isToggled {
                return container.blocksContainer.children(of: id)
            }
            else {
                return []
            }
        }
    }
    class NumberedFlattener {
        static func process(_ ids: [BlockId], in container: Container) {
            var number: Int = 0
            for id in ids {
                if let model = container.blocksContainer.choose(by: id) {
                    switch model.blockModel.information.content {
                    case let .text(value) where value.contentType == .numbered:
                        number += 1
                        var blockModel = model.blockModel
                        blockModel.information.content = .text(.init(attributedText: value.attributedText, color: value.color, contentType: value.contentType, checked: value.checked, number: number))
                    default: number = 0
                    }
                }
            }
        }
    }
}
