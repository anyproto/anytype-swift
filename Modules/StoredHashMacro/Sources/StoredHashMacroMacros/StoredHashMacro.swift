import SwiftSyntax
import SwiftSyntaxMacros
import SwiftCompilerPlugin

public struct StoredHashMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError.message("This macro can only be applied to structs")
        }
        
        // Check that the struct conforms to Hashable protocol
        guard structDecl.inheritanceClause?.inheritedTypes.contains(where: { type in
            type.type.as(IdentifierTypeSyntax.self)?.name.text == "Hashable"
        }) == true else {
            throw MacroError.message("Type must conform to Hashable protocol")
        }
        
        let members = structDecl.memberBlock.members
        let varDeclarations = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }.filter { !$0.isStatic && !($0.isLet && $0.hasInitializer) }
        
        // Create private property for storing hash
        let hashProperty = "private var _lastHash: Int = 0"
        
        // Create method for computing hash
        let hashMethod = """
        private func computeHash() -> Int {
            var hasher = Hasher()
            \(varDeclarations.map { "hasher.combine(\($0.bindings.first?.pattern.description ?? ""))" }.joined(separator: "\n    "))
            return hasher.finalize()
        }
        """
        
        // Create method for updating hash
        let updateHashMethod = """
        private mutating func updateHash() {
            _lastHash = computeHash()
        }
        """
        
        // Create hash(into:) method for Hashable protocol
        let hashIntoMethod = """
        public func hash(into hasher: inout Hasher) {
            hasher.combine(_lastHash)
        }
        """
        
        // Create == method for Equatable protocol
        let equalMethod = """
        public static func == (lhs: \(structDecl.name.text), rhs: \(structDecl.name.text)) -> Bool {
            lhs._lastHash == rhs._lastHash
        }
        """
        
        // Create public init method that calculates hash at the end
        let storedProperties = varDeclarations.filter { varDecl in
            guard let binding = varDecl.bindings.first else { return false }
            
            // If no accessor block, it's a stored property
            guard let accessorBlock = binding.accessorBlock else { return true }
            
            // Check if it's a computed property (has get/set accessors)
            switch accessorBlock.accessors {
            case .accessors(let accessorList):
                for accessor in accessorList {
                    if accessor.accessorSpecifier.tokenKind == .keyword(.get) || 
                       accessor.accessorSpecifier.tokenKind == .keyword(.set) {
                        return false // It's a computed property, exclude it
                    }
                }
                return true // Has observers like didSet/willSet
            case .getter:
                return false // It's a computed property with getter expression
            }
        }
        
        let initParameters = storedProperties.compactMap { varDecl in
            guard let binding = varDecl.bindings.first,
                  let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation else {
                return nil
            }
            return "\(pattern.identifier.text): \(typeAnnotation.type.description.trimmingCharacters(in: .whitespaces))"
        }.joined(separator: ", ")
        
        let initAssignments = storedProperties.compactMap { varDecl in
            guard let binding = varDecl.bindings.first,
                  let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                return nil
            }
            return "self.\(pattern.identifier.text) = \(pattern.identifier.text)"
        }.joined(separator: "\n    ")
        
        let initMethod = """
        public init(\(initParameters)) {
            \(initAssignments)
            self._lastHash = computeHash()
        }
        """
        
        // Return helper methods and properties
        return [
            DeclSyntax(stringLiteral: hashProperty),
            DeclSyntax(stringLiteral: hashMethod),
            DeclSyntax(stringLiteral: updateHashMethod),
            DeclSyntax(stringLiteral: hashIntoMethod),
            DeclSyntax(stringLiteral: equalMethod),
            DeclSyntax(stringLiteral: initMethod)
        ]
    }
}

enum MacroError: Error {
    case message(String)
}
