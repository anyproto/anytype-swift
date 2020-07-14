//
//  Block+CommonStructures.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = Block

public extension Namespace {
    enum Kind {
        case meta
        case block
    }
}

public extension Namespace {
    enum Focus {}
}

public extension Namespace.Focus {
    enum Position {
        case unknown
        case beginning
        case end
        case at(Int)
    }
}
