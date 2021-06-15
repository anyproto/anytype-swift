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
extension BlockToolbar {
    enum TurnIntoBlock {}
}

// MARK: View
extension BlockToolbar.TurnIntoBlock {
    typealias InputViewBuilder = BlockToolbar.AddBlock.InputViewBuilder
    typealias InputView = BlockToolbar.AddBlock.InputView
}
