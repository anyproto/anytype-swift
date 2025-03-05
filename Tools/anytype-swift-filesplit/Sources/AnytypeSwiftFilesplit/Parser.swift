import Foundation
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder

public struct SplitResult: Equatable {
    public let source: String
    public let fileName: String
}

public class FileSplitrer {
    let source: String
    let otherName: String
    let maxDepth: Int
    var imports: [ImportDeclSyntax] = []
    var fileprivateItems: [CodeBlockItemSyntax] = []
    var result: [String: SourceFileSyntax] = [:]
    var otherItems: [CodeBlockItemSyntax] = []
    
    public init(source: String, otherName: String, maxDepth: Int = 3) {
        self.source = source
        self.otherName = otherName
        self.maxDepth = maxDepth
    }
    
    public func split() -> [SplitResult] {
        
        let sourceFile = Parser.parse(source: source)
        imports.removeAll()
        result.removeAll()
        otherItems.removeAll()
        
        sourceFile.statements.forEach { itemSyntax in
            parseCodeBlockItemSyntax(itemSyntax, depth: 1)
        }
        
        var mapResults = result
            .map { (key, value) in
                var source = value
                source.statements.append(contentsOf: fileprivateItems)
                source.trailingTrivia = .newlines(1)
                return SplitResult(source: source.description, fileName: "\(key).swift")
            }
        
        if !otherItems.isEmpty {
            var sourceFile = SourceFileSyntax {
                imports
                otherItems
                fileprivateItems
            }
            sourceFile.trailingTrivia = .newlines(1)
            let other = SplitResult(source: sourceFile.description, fileName: otherName)
            mapResults.append(other)
        }
        
        return mapResults
    }
    
    private func parseCodeBlockItemSyntax(_ itemSyntax: CodeBlockItemSyntax, depth: Int) {
        switch itemSyntax.item {
        case .decl(let declSyntax):
            parseDeclSyntax(declSyntax, depth: depth, extensions: nil)
        case .stmt:
            otherItems.append(itemSyntax)
        case .expr:
            otherItems.append(itemSyntax)
        }
    }
    
    private func parseDeclSyntax(_ declSyntax: DeclSyntax, depth: Int, extensions: String?) {
        let itemSyntax = CodeBlockItemSyntax(item: .decl(declSyntax))
        if declSyntax.isFileprivate {
            fileprivateItems.append(itemSyntax)
        } else if let structV = declSyntax.as(StructDeclSyntax.self) {
            parseStruct(structV, depth: depth, extensions: extensions)
        } else if let importV = declSyntax.as(ImportDeclSyntax.self) {
            imports.append(importV)
        } else if let enumV = declSyntax.as(EnumDeclSyntax.self) {
            parseEnum(enumV, depth: depth, extensions: extensions)
        } else if let extensionV = declSyntax.as(ExtensionDeclSyntax.self) {
            let name = extensionV.extendedType.formatted().description.split(separator: ".").prefix(maxDepth).joined(separator: ".")
            if var fileSyntax = result[name] {
                fileSyntax.statements.append(itemSyntax)
                result[name] = fileSyntax
            } else {
                otherItems.append(itemSyntax)
            }
        } else if let ifConfigDecl = declSyntax.as(IfConfigDeclSyntax.self) {
            parseIfConfigDeclSyntax(ifConfigDecl, itemSyntax: itemSyntax, depth: depth)
        } else {
            otherItems.append(itemSyntax)
        }
    }
    
    private func parseIfConfigDeclSyntax(_ decl: IfConfigDeclSyntax, itemSyntax: CodeBlockItemSyntax, depth: Int) {
        for clasuse in decl.clauses {
            switch clasuse.elements {
            case .statements(let data):
                for item in data {
                    parseCodeBlockItemSyntax(item, depth: depth)
                }
            default:
                otherItems.append(itemSyntax)
            }
        }
    }
    
    private func parseStruct(_ structDecl: StructDeclSyntax, depth: Int, extensions: String?) {
        let childs = structDecl.memberBlock.members.filter { $0.decl.is(StructDeclSyntax.self) || $0.decl.is(EnumDeclSyntax.self) }
        var newStructDecl = structDecl
        
        if depth < maxDepth {
            let members = structDecl.memberBlock.members.filter { !($0.decl.is(StructDeclSyntax.self) || $0.decl.is(EnumDeclSyntax.self)) }
            newStructDecl.memberBlock.members = members
        }
        newStructDecl.leadingTrivia = Trivia.newlines(1) + (extensions != nil ? .spaces(4) : .spaces(0))
        newStructDecl.trailingTrivia = extensions != nil ? .spaces(4).merging(.newlines(1)) : .spaces(0)
                
        let sourceFile = SourceFileSyntax {
            imports
            if let extensions {
                try! ExtensionDeclSyntax("extension \(raw: extensions)") {
                    newStructDecl
                }
                .with(\.leadingTrivia, .newlines(2))
            } else {
                newStructDecl
            }
        }
        let newExtension = extensions.map { "\($0).\(newStructDecl.name.text)" } ?? newStructDecl.name.text
        result[newExtension] = sourceFile
        
        if depth < maxDepth {
            for child in childs {
                parseDeclSyntax(child.decl, depth: depth + 1, extensions: newExtension)
            }
        }
    }
    
    private func parseEnum(_ enumDecl: EnumDeclSyntax, depth: Int, extensions: String?) {
        var newEnumDecl = enumDecl
        newEnumDecl.leadingTrivia = Trivia.newlines(1) + (extensions != nil ? .spaces(4) : .spaces(0))
        newEnumDecl.trailingTrivia = extensions != nil ? .spaces(4).merging(.newlines(1)) : .spaces(0)
        
        let sourceFile = SourceFileSyntax {
            imports
            if let extensions {
                try! ExtensionDeclSyntax("extension \(raw: extensions)") {
                    enumDecl
                }
                .with(\.leadingTrivia, .newlines(2))
            } else {
                enumDecl
            }
        }
        let newExtension = extensions.map { "\($0).\(newEnumDecl.name.text)" } ?? newEnumDecl.name.text
        result[newExtension] = sourceFile
    }
}
