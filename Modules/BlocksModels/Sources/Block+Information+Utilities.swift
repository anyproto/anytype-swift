//
//  Block+Information+Utilities.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 17.09.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = Block.Information.Utilities

extension Block.Information {
    public enum Utilities {}
}

extension Namespace {
    public struct AsHashable {
        public private(set) var value: BlockInformationModelProtocol
        
        public init(value: BlockInformationModelProtocol) {
            self.value = value
        }
    }
}

extension Block.Information.Utilities.AsHashable: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value.diffable() == rhs.value.diffable()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.value.diffable())
    }
}
