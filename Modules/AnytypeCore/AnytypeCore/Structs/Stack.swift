public class Stack<T> {
    private var list: [T] = []
    
    public init() { }
    
    public var isEmpty: Bool {
        list.isEmpty
    }
    
    public func push(_ element: T) {
        list.append(element)
    }
    
    public func pop() -> T? {
        guard !isEmpty else { return nil }
        return list.removeLast()
    }    
}
