import UIKit

/// The wrapper over the LayoutAnchor.
/// Provides a more convenient API for working with constraints.
public struct LayoutProperty<Anchor: LayoutAnchorType> {
    
    private let anchor: Anchor
    
    init(anchor: Anchor) {
        self.anchor = anchor
    }
    
}

@MainActor
public extension LayoutProperty where Anchor: LayoutAnchor {
    
    /// Returns a constraint that defines one item’s attribute as equal
    /// to another item’s attribute plus a constant offset.
    ///
    /// - Parameters:
    ///   - otherAnchor: The layout anchor.
    ///   - constant: The constant offset for the constraint.
    ///   - priority: The proirity of the constraint.
    ///   - activate: Determines whether to activate the Constraint when it is created. Default is `true`.
    /// - Returns: A layout constraint.
    @discardableResult
    func equal(to otherAnchor: Anchor,
               constant: CGFloat = 0,
               priority: UILayoutPriority? = nil,
               activate: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(equalTo: otherAnchor,
                                           constant: constant)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = activate
        
        return constraint
    }
    
    /// Returns a constraint that defines one item’s attribute as greater than or equal
    /// to another item’s attribute plus a constant offset.
    ///
    /// - Parameters:
    ///   - otherAnchor: The layout anchor.
    ///   - constant: The constant offset for the constraint.
    ///   - priority: The proirity of the constraint.
    ///   - activate: Determines whether to activate the Constraint when it is created. Default is `true`.
    /// - Returns: A layout constraint.
    @discardableResult
    func greaterThanOrEqual(to otherAnchor: Anchor,
                            constant: CGFloat = 0,
                            priority: UILayoutPriority? = nil,
                            activate: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(greaterThanOrEqualTo: otherAnchor,
                                           constant: constant)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = activate
        
        return constraint
    }
    
    /// Returns a constraint that defines one item’s attribute as less than or equal
    /// to another item’s attribute plus a constant offset.
    ///
    /// - Parameters:
    ///   - otherAnchor: The layout anchor.
    ///   - constant: The constant offset for the constraint.
    ///   - priority: The proirity of the constraint.
    ///   - activate: Determines whether to activate the Constraint when it is created. Default is `true`.
    /// - Returns: A layout constraint.
    @discardableResult
    func lessThanOrEqual(to otherAnchor: Anchor,
                         constant: CGFloat = 0,
                         priority: UILayoutPriority? = nil,
                         activate: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(lessThanOrEqualTo: otherAnchor,
                                           constant: constant)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = activate
        
        return constraint
    }
    
}

@MainActor
public extension LayoutProperty where Anchor: LayoutDimension {
    
    /// Returns a constraint that defines a constant size for the anchor’s size attribute.
    ///
    /// - Parameters:
    ///   - constant: A constant representing the size of the attribute associated with this dimension anchor.
    ///   - priority: The proirity of the constraint.
    ///   - activate: Determines whether to activate the Constraint when it is created. Default is `true`.
    /// - Returns: An `NSLayoutConstraint` object that defines a constant size for the attribute
    /// associated with this dimension anchor.
    @discardableResult
    func equal(to constant: CGFloat,
               priority: UILayoutPriority? = nil,
               activate: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(equalToConstant: constant)
        
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = activate
        
        return constraint
    }
    
 /// Returns a constraint that defines the minimubm size for the anchor’s size attribute.
    ///
    /// - Parameters:
    ///   - constant: A constant representing the size of the attribute associated with this dimension anchor.
    ///   - priority: The proirity of the constraint.
    ///   - activate: Determines whether to activate the Constraint when it is created. Default is `true`.
    /// - Returns: An `NSLayoutConstraint` object that defines a minimum size for the attribute
    /// associated with this dimension anchor.
    @discardableResult
    func greaterThanOrEqual(to constant: CGFloat,
                            priority: UILayoutPriority? = nil,
                            activate: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(greaterThanOrEqualToConstant: constant)
        
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = activate
        
        return constraint
    }
    
    /// Returns a constraint that defines the maximum size for the anchor’s size attribute.
    ///
    /// - Parameters:
    ///   - constant: A constant representing the size of the attribute associated with this dimension anchor.
    ///   - priority: The proirity of the constraint.
    ///   - activate: Determines whether to activate the Constraint when it is created. Default is `true`.
    /// - Returns: An `NSLayoutConstraint` object that defines a maximum size for the attribute
    /// associated with this dimension anchor.
    @discardableResult
    func lessThanOrEqual(to constant: CGFloat,
                         priority: UILayoutPriority? = nil,
                         activate: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(lessThanOrEqualToConstant: constant)
        
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = activate
        
        return constraint
    }
    
    @discardableResult
    func equal(to property: LayoutProperty,
               priority: UILayoutPriority? = nil,
               multiplier: CGFloat = 1,
               activate: Bool = true) -> NSLayoutConstraint {
        guard property.anchor is NSLayoutDimension else {
            return equal(to: 0)
        }
        return equal(to: property.anchor, priority: priority, multiplier: multiplier, activate: activate)
    }
    
    /// Returns a constraint that defines one item’s attribute as equal
    /// to another item’s attribute multiplied by a multiplier.
    ///
    /// - Parameters:
    ///   - otherAnchor: The layout anchor.
    ///   - priority: The proirity of the constraint.
    ///   - multiplier: The multiplier for the constraint.
    ///   - activate: Determines whether to activate the Constraint when it is created. Default is `true`.
    /// - Returns: A layout constraint.
    @discardableResult
    func equal(to otherAnchor: Anchor,
               priority: UILayoutPriority? = nil,
               multiplier: CGFloat,
               activate: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(equalTo: otherAnchor, multiplier: multiplier)

        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = activate

        return constraint
    }
    
    /// Returns a constraint that defines one item’s attribute as less than or equal
    /// to another item’s attribute multiplied by a multiplier.
    ///
    /// - Parameters:
    ///   - otherAnchor: The layout anchor.
    ///   - priority: The proirity of the constraint.
    ///   - activate: Determines whether to activate the Constraint when it is created. Default is `true`.
    /// - Returns: A layout constraint.
    @discardableResult
    func lessThanOrEqual(to otherAnchor: Anchor,
                         priority: UILayoutPriority? = nil,
                         multiplier: CGFloat,
                         activate: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(lessThanOrEqualTo: otherAnchor, multiplier: multiplier)
        
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = activate
        
        return constraint
    }
    
    /// Returns a constraint that defines one item’s attribute as greater than or equal
    /// to another item’s attribute multiplied by a multiplier.
    ///
    /// - Parameters:
    ///   - otherAnchor: The layout anchor.
    ///   - priority: The proirity of the constraint.
    ///   - activate: Determines whether to activate the Constraint when it is created. Default is `true`.
    /// - Returns: A layout constraint.
    @discardableResult
    func greaterThanOrEqual(to otherAnchor: Anchor,
                            priority: UILayoutPriority? = nil,
                            multiplier: CGFloat,
                            activate: Bool = true) -> NSLayoutConstraint {
        let constraint = anchor.constraint(greaterThanOrEqualTo: otherAnchor, multiplier: multiplier)
        
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.isActive = activate
        
        return constraint
    }
    
}
