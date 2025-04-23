import UIKit
import SwiftUI


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
