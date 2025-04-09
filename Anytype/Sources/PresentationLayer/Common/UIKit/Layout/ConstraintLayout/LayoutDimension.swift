import UIKit

/// The protocol describing a factory object for creating size-based layout constraint objects.
@MainActor
public protocol LayoutDimension: LayoutAnchorType {
    
    /// Returns a constraint that defines a constant size for the anchor’s size attribute.
    ///
    /// - Parameter constant: A constant representing the size of the attribute associated with this dimension anchor.
    /// - Returns: An `NSLayoutConstraint` object that defines a constant size for the attribute
    /// associated with this dimension anchor.
    func constraint(equalToConstant constant: CGFloat) -> NSLayoutConstraint
    
    /// Returns a constraint that defines the minimum size for the anchor’s size attribute.
    ///
    /// - Parameter constant: A constant representing the size of the attribute associated with this dimension anchor.
    /// - Returns: An `NSLayoutConstraint` object that defines a minimum size for the attribute
    /// associated with this dimension anchor.
    func constraint(greaterThanOrEqualToConstant constant: CGFloat) -> NSLayoutConstraint
    
    /// Returns a constraint that defines the maximum size for the anchor’s size attribute.
    ///
    /// - Parameter constant: A constant representing the size of the attribute associated with this dimension anchor.
    /// - Returns: An `NSLayoutConstraint` object that defines a maximum size for the attribute
    /// associated with this dimension anchor.
    func constraint(lessThanOrEqualToConstant constant: CGFloat) -> NSLayoutConstraint

    /// Returns a constraint that defines one item’s attribute as equal
    /// to another item’s attribute multiplied by a multiplier.
    ///
    /// - Parameters:
    ///   - anchor: The layout anchor.
    ///   - multiplier: The multiplier for the constraint.
    /// - Returns: An inactive constraint.
    func constraint(equalTo anchor: Self, multiplier: CGFloat) -> NSLayoutConstraint
    
    /// Returns a constraint that defines one item’s attribute as greater than or equal
    /// to another item’s attribute multiplied by a multiplier.
    ///
    /// - Parameters:
    ///   - anchor: The layout anchor.
    ///   - multiplier: The multiplier for the constraint.
    /// - Returns: An inactive constraint.
    func constraint(greaterThanOrEqualTo anchor: Self, multiplier: CGFloat) -> NSLayoutConstraint

    /// Returns a constraint that defines one item’s attribute as less than or equal
    /// to another item’s attribute multiplied by a multiplier.
    ///
    /// - Parameters:
    ///   - anchor: The layout anchor.
    ///   - multiplier: The multiplier for the constraint.
    /// - Returns: An inactive constraint.
    func constraint(lessThanOrEqualTo anchor: Self, multiplier: CGFloat) -> NSLayoutConstraint
}

extension NSLayoutDimension: LayoutDimension {}
