//
//  BlocksViews+Toolbar+TurnIntoBlock.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

// MARK: TurnInto
extension BlocksViews.Toolbar {
    enum TurnIntoBlock {}
}

// MARK: View
extension BlocksViews.Toolbar.TurnIntoBlock {
    typealias InputViewBuilder = BlocksViews.Toolbar.AddBlock.InputViewBuilder
    typealias InputView = BlocksViews.Toolbar.AddBlock.InputView
}
