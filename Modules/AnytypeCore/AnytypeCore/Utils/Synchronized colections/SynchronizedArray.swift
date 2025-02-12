/// A thread-safe array.
import Foundation

public final class SynchronizedArray<T>: @unchecked Sendable {

    // MARK: - Private variables

    private var storage: [T]
    private let lock = NSLock()

    // MARK: - Initializers

    public init(array: [T] = []) {
        self.storage = array
    }

    // MARK: - Public functions

    public var array: [T] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }
    
    public func append(_ newElement: T) {
        lock.lock()
        storage.append(newElement)
        lock.unlock()
    }
    
    public func append(contentsOf newElements: [T]) {
        lock.lock()
        storage.append(contentsOf: newElements)
        lock.unlock()
    }

    public subscript(index: Int) -> T {
        get {
            var element: T!

            lock.lock()
            element = self.storage[index]
            lock.unlock()

            return element
        }
        set {
            lock.lock()
            storage[index] = newValue
            lock.unlock()
        }
    }

    @discardableResult
    public func removeFirst() -> T {
        lock.lock()
        let first = storage.removeFirst()
        lock.unlock()

        return first
    }

    public var first: T? {
        lock.lock()
        let first = storage.first
        lock.unlock()

        return first
    }

    public var count: Int {
        lock.lock()
        let count = storage.count
        lock.unlock()

        return count
    }

    public func forEach(_ body: (T) throws -> Void) rethrows {
        lock.lock()
        try storage.forEach(body)
        lock.unlock()
    }

    public func removeAll() {
        lock.lock()
        storage.removeAll()
        lock.unlock()
    }

    public func removeAll(where shouldBeRemoved: (T) -> Bool) {
        lock.lock()
        storage.removeAll(where: shouldBeRemoved)
        lock.unlock()
    }
    
    public func mutate(_ closure: (_ array: inout [T]) -> Void)  {
        lock.lock()
        closure(&storage)
        lock.unlock()
    }
}

