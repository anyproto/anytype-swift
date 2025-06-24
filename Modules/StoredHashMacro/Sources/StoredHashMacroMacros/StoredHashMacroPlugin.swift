import SwiftSyntax
import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct StoredHashMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StoredHashMacro.self
    ]
} 
