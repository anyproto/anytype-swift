class Stack<T> {
    private var list: [T] = []
    
    var isEmpty: Bool {
        list.isEmpty
    }
    
    func push(_ element: T) {
        list.append(element)
    }
    
    func pop() -> T? {
        guard !isEmpty else { return nil }
        return list.removeLast()
    }    
}
