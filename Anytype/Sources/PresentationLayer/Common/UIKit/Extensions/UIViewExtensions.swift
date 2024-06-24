//
//  UIViewExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 11.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit
import SwiftUI

// MARK: - Constraints

public extension UIView {
    
    /// Pins all edges of view to a given view with zero insets.
    ///
    /// This function adds top, bottom, leading and trailinig constraints with zero insets.
    ///
    /// - Parameter view: The view to pin edges.
    func pinAllEdges(to view: UIView) {
        pinAllEdges(to: view, insets: .zero)
    }
    
    /// Pins all edges of view to a given view with specified insets.
    ///
    /// This function adds top, bottom, leading and trailinig constraints with specified insets.
    ///
    /// - Parameters:
    ///   - view: The view to pin edges.
    ///   - insets: The insets for all edges.
    func pinAllEdges(to view: UIView, insets: UIEdgeInsets) {
        layoutUsing.anchors {
            $0.pin(to: view, insets: insets)
        }
    }
    
}

// MARK: - Subviews enumeration

public extension UIView {

    /// Adds an array of subviews
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }

    /// Removes all subviews. Duh
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// Performs an operation with each subview (recursively).
    /// - Parameter closure: The closure to perform with each subview.
    func forEachSubview(closure: (UIView) -> Void) {
        subviews.forEach {
            closure($0)
            $0.forEachSubview(closure: closure)
        }
    }
    
}

// MARK: - Container

public extension UIView {
    
    /// Embeds the view in a container with the specified insets.
    /// - Parameter insets: The insets to use in the container. Set as layout margins of the container view
    /// - Returns: The created container view
    func embedInContainer(withInsets insets: UIEdgeInsets) -> UIView {
        let container = UIView()
        container.addSubview(self)
        container.layoutMargins = insets
        layoutUsing.anchors { $0.pin(to: container.layoutMarginsGuide) }
        return container
    }
    
    func embedInCenterOfContainer() -> UIView {
        let container = UIView()
        container.addSubview(self)
        layoutUsing.anchors {
            $0.centerX.equal(to: container.centerXAnchor)
            $0.centerY.equal(to: container.centerYAnchor)
        }
        return container
    }
    
}

// MARK: - Draw
extension UIView {
    func drawToImage() -> UIImage {
        let currentStyle = overrideUserInterfaceStyle
        
        overrideUserInterfaceStyle = .light
        let lightImage = drawToImageInternal()
        
        overrideUserInterfaceStyle = .dark
        let darkImage = drawToImageInternal()
        
        overrideUserInterfaceStyle = currentStyle
        
        return UIImage.dynamicImage(light: lightImage, dark: darkImage)
    }
    
    private func drawToImageInternal() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { ctx in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        return image
    }
}

// MARK: - Debug view hierarchy

public extension UIView {
    
    func countChildsRecursively() -> Int {
        guard !subviews.isEmpty else {
            return 1 // count only self
        }
        
        let count: Int = subviews.reduce(0) {
            $0 + $1.countChildsRecursively()
        }
        
        return count
    }
    
    func fillSubviewsWithRandomColors(recursively: Bool = true) {
        let childsCount = recursively
            ? countChildsRecursively()
            : subviews.count
        
        var colors = generateRandomColors(ofCount: childsCount + 1)
        let selfColor = colors.popLast()
        
        backgroundColor = selfColor
        
        fillWithRandomColors(colors: &colors, recursively: recursively)
    }
    
    private func fillWithRandomColors(colors: inout [UIColor], recursively: Bool = true) {
        for subview in subviews {
            guard let color = colors.popLast() else {
                return
            }
            
            if recursively {
                subview.fillWithRandomColors(colors: &colors, recursively: recursively)
            }
            
            subview.backgroundColor = color
        }
    }
    
    private func generateRandomColors(ofCount count: Int) -> [UIColor] {
        (0..<count).map { _ in
            UIColor.randomColor()
        }
    }
}

extension View {
    func asUIView() -> UIView {
        UIHostingController(rootView: self).view
    }
}
