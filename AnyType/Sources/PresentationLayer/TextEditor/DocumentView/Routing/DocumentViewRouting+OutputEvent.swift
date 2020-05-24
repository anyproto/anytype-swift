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
    /// For now we can pass controllers without additional dismissal actions and they will be dismissed by theirselves
    enum OutputEvent {
        case showViewController(UIViewController)
        case pushViewController(UIViewController)
    }
}
