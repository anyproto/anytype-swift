//
//  BlocksModels+Updater.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 05.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//
import Foundation

import os

fileprivate typealias Namespace = BlocksModels

private extension Logging.Categories {
    static let blocksModelsUpdater: Self = "BlocksModels.Updater"
}
extension Namespace {
    class Updater {
        typealias BlockId = BlocksModels.Aliases.BlockId
        typealias Key = BlockId
        typealias Container = BlocksModelsContainerModelProtocol
        typealias Model = BlocksModelsBlockModelProtocol

        private var container: Container

        init(_ container: Container) {
            self.container = container
        }
    }
}

// MARK: Updater / Actions
// MARK: Updater / Actions / Delete
extension Namespace.Updater {
    /// Delete entry from a container
    /// - Parameter at: at is an associated key to this entry.
    func delete(at: Key) {
        self.container.remove(at)
    }
}

// MARK: Updater / Actions / Insert
extension Namespace.Updater {
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
        self.container.add(block)
        self.container.add(child: block.information.id, beforeChild: at)
    }
    
    /// Like a method above, it do the same with the same warnings and notes.
    ///
    /// But it will insert entry AFTER an entry that could be found by associated key.
    ///
    /// - Parameters:
    ///   - block: A model that we would like to insert in our container.
    ///   - at: an associated key to an entry.
    func insert(block: Model, afterblock at: Key) {
        self.container.add(block)
        self.container.add(child: block.information.id, afterChild: at)
    }
    
    /// Unlike other methods, this method only insert a model into a container.
    /// To build correct container, you should run method `buildTree` of a `BuilderProtocol` entry.
    /// - Parameter block: A model that we would like to insert in our container.
    func insert(block: Model) {
        self.container.add(block)
    }
}

// MARK: Updater / Actions / Set Children
extension Namespace.Updater {
    /// Set new children to parent.
    /// It depends on implementation what exactly do children.
    /// For now we don't care about their new parent, it will be set after `buildTree` of a `BuilderProtocol` entry.
    /// - Parameters:
    ///   - children: new associated keys of children that will be set to parent.
    ///   - parent: an associated key to parent entry.
    func set(children: [Key], parent: Key) {
        self.container.replace(childrenIds: children, parentId: parent, shouldSkipGuardAgainstMissingIds: true)
    }
}

// MARK: Updater / Actions / Update Style (?)
extension Namespace.Updater {
    /// This is the only one valid way to update properties of entry.
    /// Do not try to update it somehow else, please.
    /// - Parameters:
    ///   - key: associated key to an entry that we would like to update.
    ///   - update: update-closure that we would like to apply to an entry.
    /// - Returns: Nothing, heh
    func update(entry key: Key, update: @escaping (Model) -> ()) {
        guard let entry = self.container.get(by: key) else {
            let logger = Logging.createLogger(category: .blocksModelsUpdater)
            os_log(.debug, log: logger, "We haven't found an entry by key: %@", key)
            return
        }
        update(entry)
        entry.didChange()
    }
}
