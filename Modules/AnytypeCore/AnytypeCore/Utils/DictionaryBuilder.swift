import Foundation

@resultBuilder
public struct DictionaryBuilder<Key: Hashable, Value>  {
    
    public typealias Component = Dictionary<Key, Value>
    
    public static func buildBlock() -> Component { [:] }
    public static func buildBlock(_ component: Component) -> Component { component }
    public static func buildBlock(_ components: Component...) -> Component {
        components.reduce(into: [:]) { result, next in
            result.merge(next) { $1 }
        }
    }
    public static func buildOptional(_ component: Component?) -> Component { component ?? [:] }
    public static func buildEither(first component: Component) -> Component { component }
    public static func buildEither(second component: Component) -> Component { component}
    public static func buildLimitedAvailability(_ component: Component) -> Component { component }
}

public extension Dictionary {
    init(@DictionaryBuilder<Key, Value> content: @escaping () -> Self) {
        self = content()
    }
}
