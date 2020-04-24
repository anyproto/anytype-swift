//
//  TextView+ActionsToolbar.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 23.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

extension TextView {
    enum ActionsToolbar {}
}

// MARK: Style
extension TextView.ActionsToolbar {
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
