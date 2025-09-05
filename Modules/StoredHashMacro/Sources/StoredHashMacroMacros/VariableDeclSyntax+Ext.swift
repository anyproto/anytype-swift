import SwiftSyntax

extension VariableDeclSyntax {
    var isStatic: Bool {
        return modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.static)
        }
    }
    
    var isLet: Bool {
        return bindingSpecifier.tokenKind == .keyword(.let)
    }
    
    var hasInitializer: Bool {
        return bindings.contains { $0.initializer != nil }
    }
    
    var hasComputedBindings: Bool {
        bindings.contains { $0.isComputedProperty }
    }
}

extension PatternBindingSyntax {
    /// Returns true if the property is computed (has a getter),
    /// false if it's a stored property (even if it has observers).
    var isComputedProperty: Bool {
        guard let accessorBlock = self.accessorBlock else {
            return false // No accessorBlock → definitely stored
        }
        switch accessorBlock.accessors {
        case .getter(_):
            return true // `var foo: T { ... }`
        case .accessors(let list):
            // Computed if it has a `get` accessor (with or without a body).
            return list.contains { $0.accessorSpecifier.tokenKind == .keyword(.get) }
        }
    }
}
