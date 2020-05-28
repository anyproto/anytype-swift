//
//  MarksPane.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

/// We have Input view that consists of:
/// 1. SegmentControl
/// 2. Panes
/// 3. Close button
///
/// This view is used as InputView and also it gets values from selected text.
///

enum MarksPane {}

// MARK: Style
extension MarksPane {
    enum Style {
        static let `default`: Self = .presentation
        case presentation
        func backgroundColor() -> UIColor {
            switch self {
            case .presentation: return .init(red: 0.953, green: 0.949, blue: 0.925, alpha: 1) // #F3F2EC
            }
        }
    }
}

