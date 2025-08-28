import Foundation

@resultBuilder
public struct ArrayBuilder<Element> {
    public static func buildPartialBlock(first: Element) -> [Element] { [first] }
    public static func buildPartialBlock(first: Element?) -> [Element] { first.map { [$0] } ?? [] }
    public static func buildPartialBlock(first: [Element]) -> [Element] { first }
    public static func buildPartialBlock(accumulated: [Element], next: Element) -> [Element] { accumulated + [next] }
    public static func buildPartialBlock(accumulated: [Element], next: Element?) -> [Element] { accumulated + (next.map { [$0] } ?? []) }
    public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] { accumulated + next }
    
    public static func buildBlock() -> [Element] { [] }
    // If/Else
    public static func buildEither(first: [Element]) -> [Element] { first }
    public static func buildEither(second: [Element]) -> [Element] { second }
    // For
    public static func buildArray(_ components: [[Element]]) -> [Element] { components.flatMap { $0 } }
    // Just ifs
    public static func buildIf(_ element: [Element]?) -> [Element] { element ?? [] }
    // fatalError()
    public static func buildPartialBlock(first: Never) -> [Element] {}
}

// MARK: - Array extensions
public extension Array {
    static func builder(@ArrayBuilder<Element> builder: () -> [Element]) -> Array<Element> {
        return Array(builder())
    }
}
