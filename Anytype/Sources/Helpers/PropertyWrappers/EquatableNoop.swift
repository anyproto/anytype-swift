import Foundation

@propertyWrapper
struct EquatableNoop<Value>: Equatable, Hashable {
    var wrappedValue: Value

    static func == (lhs: EquatableNoop<Value>, rhs: EquatableNoop<Value>) -> Bool { true }

    func hash(into hasher: inout Hasher) {}
}
