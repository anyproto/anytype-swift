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
//        private var finder: Finder<Wrapped>
//        private var relaxing: Relaxing = .init()
//        private var value: Wrapped
//        private var indexDictionary: DataStructures.IndexDictionary<Key> = .init()

        // MARK: Make ContinousIndexDictionary as Subclass of IndexDictionary.
//        private var hashDictionary: Dictionary<Id, Key> = .init()

//        func configured(_ value: Wrapped) -> Self {
//            self.value = value
//            self.finder = .init(value: value)
//            self.relaxing.update(finder: self.finder)
//            return self
//        }

//        init(value: Wrapped) {
//            self.value = value
//            self.finder = .init(value: value)
//            self.relaxing.update(finder: self.finder)
//        }
        init(_ container: Container) {
            self.container = container
        }
    }
}

// MARK: Update.
extension BlocksModels.Updater {
//    private func syncDictionary(_ values: [FullIndex]) {
//        self.indexDictionary.update(values)
//    }
//    func update(builders: [Wrapped]) {
////        self.syncDictionary(builders.compactMap{$0.id})
////        self.builders = builders
//    }
}

// MARK: Updater / Updates
extension BlocksModels.Updater {
    func delete(at: Key) {
        self.container.remove(at)
    }
    
    func insert(block: Model, at: Key) {
        self.container.add(block)
        self.container.add(child: block.information.id, beforeChild: at)
    }
    
    func insert(block: Model, afterblock at: Key) {
        self.container.add(block)
        self.container.add(child: block.information.id, afterChild: at)
    }
}
