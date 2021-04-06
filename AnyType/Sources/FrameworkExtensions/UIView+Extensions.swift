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
    
    /// Add constraints to superview
    ///
    /// - Parameters:
    ///   - insets: Insets
    func edgesToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

extension UIView {
    /// ConfiguredView.
    /// You could set any IntrinsicContentSize, because by
    private class ConfiguredView: UIView {
        var customIntrinsicContentSize: CGSize = .init(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        func configured(customIntrinsicContentSize: CGSize) -> Self {
            self.customIntrinsicContentSize = customIntrinsicContentSize
            return self
        }
        override var intrinsicContentSize: CGSize { customIntrinsicContentSize }
    }
    static func empty() -> UIView { ConfiguredView().configured(customIntrinsicContentSize: .zero) }
}
