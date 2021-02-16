//
//  TopLevel+Container.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = TopLevel

extension Namespace {
    /// The main intention of this class is to store rootId and store all containers together.
    /// As soon as we don't use rootId in `Block.Container`, it is safe to transfer it here.
    ///
    final class Container {
        private var _rootId: BlockId?
        private var _blocksContainer: BlockContainerModelProtocol = Builder.blockBuilder.emptyContainer()
        private var _detailsContainer: DetailsContainerModelProtocol = Builder.detailsBuilder.emptyContainer()
    }
}

extension Namespace.Container: TopLevelContainerModelProtocol {
    var rootId: BlockId? {
        get {
            self._rootId
        }
        set {
            self._rootId = newValue
        }
    }
    var blocksContainer: BlockContainerModelProtocol {
        get {
            self._blocksContainer
        }
        set {
            self._blocksContainer = newValue
        }
    }
    var detailsContainer: DetailsContainerModelProtocol {
        get {
            self._detailsContainer
        }
        set {
            self._detailsContainer = newValue
        }
    }
}
