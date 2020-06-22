//
//  MultiSelectionPane.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

enum MultiSelectionPane {}

// MARK: Style
extension MultiSelectionPane {
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
