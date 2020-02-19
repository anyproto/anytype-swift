//
//  UIView+Extensions.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import os

private extension Logging.Categories {
    static let uikitUIViewExtensions: Self = "UIKit.UIView.Extensions"
}

extension UIView {
    static func outputSubviews(_ view: UIView) {        
        let logger = Logging.createLogger(category: .uikitUIViewExtensions)
        os_log(.debug, log: logger, "%s", "\(self.readSubviews(view))")
    }
    static func readSubviews(_ view: UIView) -> [(String, CGRect)] {
        [(String(reflecting: type(of: view)), view.frame)] + view.subviews.flatMap(readSubviews)
    }
    static func outputResponderChain(_ responder: UIResponder?) {
        let chain = sequence(first: responder, next: {$0?.next}).compactMap({$0}).reduce("") { (result, responder) -> String in
            result + " -> \(String(describing: type(of: responder)))"
        }
        let logger = Logging.createLogger(category: .uikitUIViewExtensions)
        os_log(.debug, log: logger, "%s chain: %s", "\(self)", "\(chain)")
    }
}
