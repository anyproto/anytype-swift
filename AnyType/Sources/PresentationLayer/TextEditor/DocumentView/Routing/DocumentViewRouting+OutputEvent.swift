//
//  DocumentViewRouting+OutputEvent.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
extension DocumentViewRouting {
    /// Segue, yes, kind of.
    enum OutputEvent {
        case showViewController(UIViewController)
        case pushViewController(UIViewController)
    }
}
