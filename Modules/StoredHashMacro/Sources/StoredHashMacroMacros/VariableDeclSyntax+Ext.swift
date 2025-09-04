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
}
