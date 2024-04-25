final class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}
