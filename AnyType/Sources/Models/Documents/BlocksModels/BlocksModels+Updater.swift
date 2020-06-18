//
//  BlocksModels+Updater.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 05.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//
import Foundation

extension BlocksModels {
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

// MARK: Updater / Updates
extension BlocksModels.Updater {
    // MARK: - Delete
    
    /// Delete entry from a container
    /// - Parameter at: at is an associated key to this entry.
    func delete(at: Key) {
        self.container.remove(at)
    }
    
    // MARK: - Insert
    
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
    
    // MARK: - Set Children
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
