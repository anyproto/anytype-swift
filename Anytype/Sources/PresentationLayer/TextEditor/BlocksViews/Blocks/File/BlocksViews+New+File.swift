//
//  BlocksViews+New+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import BlocksModels

fileprivate typealias Namespace = BlocksViews.File

extension Namespace {
    enum File {} // -> File.ContentType.file
    enum Image {} // -> Image.ContentType.image
    enum Base {}
}
