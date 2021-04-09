//
//  Block+Tools+Updater.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import os

fileprivate typealias Namespace = Block.Tools

private extension Logging.Categories {
    static let blocksModelsToolsUpdater: Self = "BlocksModels.Tools.Updater"
}

public extension Namespace {
    class Updater {
        public typealias Key = BlockId
        public typealias Model = BlockModelProtocol

        private var container: TopLevelContainerModelProtocol

        public init(_ container: TopLevelContainerModelProtocol) {
            self.container = container
        }
    }
}

// MARK: Updater / Actions
// MARK: Updater / Actions / Delete
public extension Namespace.Updater {
    /// Delete entry from a container
    /// - Parameter at: at is an associated key to this entry.
    func delete(at: Key) {
        self.container.blocksContainer.remove(at)
    }
}

// MARK: Updater / Actions / Insert
public extension Namespace.Updater {
    /// Insert block at position of an entry that is found by key.
    ///
    /// Notes
    /// If entry is not found, its all about implementaion how to handle this error.
    ///
    /// Warning
    /// It is complex action. It consists of two actions.
    /// 1. Add entry to container
    /// 2. Find correct place of this entry in a container.
    ///
    /// IF something goes wrong in second step, entry WILL be added to a container but we don't know about it place.
    ///
    /// - Parameters:
    ///   - block: A model that we would like to insert in our container.
    ///   - at: an associated key to an entry.
    func insert(block: Model, at: Key) {
        self.insert(block: block)
        self.container.blocksContainer.add(child: block.information.id, beforeChild: at)
    }
    
    /// Like a method above, it do the same with the same warnings and notes.
    ///
    /// But it will insert entry AFTER an entry that could be found by associated key.
    ///
    /// - Parameters:
    ///   - block: A model that we would like to insert in our container.
    ///   - at: an associated key to an entry.
    func insert(block: Model, afterblock at: Key) {
        self.insert(block: block)
        self.container.blocksContainer.add(child: block.information.id, afterChild: at)
    }
    
    /// Unlike other methods, this method only insert a model into a container.
    /// To build correct container, you should run method `buildTree` of a `BuilderProtocol` entry.
    /// - Parameter block: A model that we would like to insert in our container.
    func insert(block: Model) {
        self.container.blocksContainer.add(block)
        /// When we store new page link block, we also need to add details information with identifier from this page link block
        /// Then we can update our page link block view, when details will be updated with .blockSetDetails event
        /// We receive this two events (blockAdd and blockSetDetails) in different messages
        if case let .link(link) = block.information.content {
            var details = Details.Information.InformationModel([])
            details.parentId = link.targetBlockID
            let model = Details.DetailsModel(details: details)
            self.container.detailsContainer.add(model)
        }
    }
}

// MARK: Updater / Actions / Set Children
public extension Namespace.Updater {
    /// Set new children to parent.
    /// It depends on implementation what exactly do children.
    /// For now we don't care about their new parent, it will be set after `buildTree` of a `BuilderProtocol` entry.
    /// - Parameters:
    ///   - children: new associated keys of children that will be set to parent.
    ///   - parent: an associated key to parent entry.
    func set(children: [Key], parent: Key) {
        self.container.blocksContainer.replace(childrenIds: children, parentId: parent, shouldSkipGuardAgainstMissingIds: true)
    }
}

// MARK: Updater / Actions / Update Style (?)
public extension Namespace.Updater {
    /// This is the only one valid way to update properties of entry.
    /// Do not try to update it somehow else, please.
    /// - Parameters:
    ///   - key: associated key to an entry that we would like to update.
    ///   - update: update-closure that we would like to apply to an entry.
    /// - Returns: Nothing, heh
    func update(entry key: Key, update: @escaping (Model) -> ()) {
        guard let entry = self.container.blocksContainer.get(by: key) else {
            let logger = Logging.createLogger(category: .blocksModelsToolsUpdater)
            os_log(.debug, log: logger, "We haven't found an entry by key: %@", key)
            return
        }
        update(entry)
        /// It is unnecessary, because previously `didChange` call `objectWillChange` publisher.
        /// Now we separate `didChangePublisher` and `objectWillChange` publisher.
//        entry.didChange()
    }
}
