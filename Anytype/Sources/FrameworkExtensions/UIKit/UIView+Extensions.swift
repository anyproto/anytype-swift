import Foundation
import UIKit
import os

private extension LoggerCategory {
    static let uikitUIViewExtensions: Self = "UIKit.UIView.Extensions"
}

extension UIView {
    static func outputSubviews(_ view: UIView) {        
        Logger.create( .uikitUIViewExtensions).debug("\(self.readSubviews(view))")
    }
    static func readSubviews(_ view: UIView) -> [(String, CGRect)] {
        [(String(reflecting: type(of: view)), view.frame)] + view.subviews.flatMap(readSubviews)
    }
    static func outputResponderChain(_ responder: UIResponder?) {
        let chain = sequence(first: responder, next: {$0?.next}).compactMap({$0}).reduce("") { (result, responder) -> String in
            result + " -> \(String(describing: type(of: responder)))"
        }
        Logger.create( .uikitUIViewExtensions).debug("\(self) chain: \(chain)")
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
    
    func renderedImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func isAnySubviewFirstResponder() -> Bool {
        if isFirstResponder {
            return true
        }
        for subview in subviews {
            if subview.isAnySubviewFirstResponder() {
                return true
            }
        }
        return false
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
