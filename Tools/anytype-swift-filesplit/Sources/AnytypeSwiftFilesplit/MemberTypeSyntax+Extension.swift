import SwiftSyntax

extension DeclSyntax {
    
    var isFileprivate: Bool {
        if let funcDecl = self.as(FunctionDeclSyntax.self) {
            return funcDecl.modifiers.contains { $0.name.tokenKind == .keyword(.fileprivate) }
        }
        
        if let varDecl = self.as(VariableDeclSyntax.self) {
            return varDecl.modifiers.contains { $0.name.tokenKind == .keyword(.fileprivate) }
        }
        
        if let structDecl = self.as(StructDeclSyntax.self) {
            return structDecl.modifiers.contains { $0.name.tokenKind == .keyword(.fileprivate) }
        }
        
        if let classDecl = self.as(ClassDeclSyntax.self) {
            return classDecl.modifiers.contains { $0.name.tokenKind == .keyword(.fileprivate) }
        }
        
        return false
    }
}
