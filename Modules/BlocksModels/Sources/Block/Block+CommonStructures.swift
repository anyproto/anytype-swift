//
//  Block+CommonStructures.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = Block
fileprivate typealias FileNamespace = Block.Common

public extension Namespace {
    enum Common {}
}

public extension FileNamespace {
    enum Kind {
        case meta
        case block
    }
}

public extension FileNamespace {
    enum Position {
        case none
        case top, bottom
        case left, right
        case inner
        case replace
    }
}

public extension FileNamespace {
    enum Focus {
        public enum Position {
            case unknown
            case beginning
            case end
            case at(Int)
        }
    }
}

