//
//  BlocksViews+New+Unknown.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 05.11.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.New.Unknown

// This is special kind of blocks. If we want, we could skip all blocks and show all blocks as "Unknown".

extension Namespace {
    enum Label {}
    enum Base {}
}

extension Namespace.Base {
    class ViewModel: BlocksViews.New.Base.ViewModel {}
}


