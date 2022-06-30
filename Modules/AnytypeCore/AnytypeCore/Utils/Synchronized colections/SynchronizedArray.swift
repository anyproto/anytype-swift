/// A thread-safe array.
import Foundation

public final class SynchronizedArray<T> {

    // MARK: - Private variables

    public private(set) var array: [T]
    private let lock = NSLock()

    // MARK: - Initializers

    public init(array: [T] = []) {
        self.array = array
    }

    // MARK: - Public functions

    public func append(_ newElement: T) {
        lock.lock()
        array.append(newElement)
        lock.unlock()
    }
    
    public func append(contentsOf newElements: [T]) {
        lock.lock()
        array.append(contentsOf: newElements)
        lock.unlock()
    }

    public subscript(index: Int) -> T {
        get {
            var element: T!

            lock.lock()
            element = self.array[index]
            lock.unlock()

            return element
        }
        set {
            lock.lock()
            array[index] = newValue
            lock.unlock()
        }
    }

    @discardableResult
    public func removeFirst() -> T {
        lock.lock()
        let first = array.removeFirst()
        lock.unlock()

        return first
    }

    public var first: T? {
        lock.lock()
        let first = array.first
        lock.unlock()

        return first
    }

    public var count: Int {
        lock.lock()
        let count = array.count
        lock.unlock()

        return count
    }

    public func forEach(_ body: (T) throws -> Void) rethrows {
        lock.lock()
        try array.forEach(body)
        lock.unlock()
    }

    public func removeAll() {
        lock.lock()
        array.removeAll()
        lock.unlock()
    }

    public func removeAll(where shouldBeRemoved: (T) -> Bool) {
        lock.lock()
        array.removeAll(where: shouldBeRemoved)
        lock.unlock()
    }
    
}

