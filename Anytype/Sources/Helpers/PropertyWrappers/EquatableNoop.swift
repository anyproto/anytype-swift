import Foundation

@propertyWrapper
struct EquatableNoop<Value>: Equatable {
    var wrappedValue: Value

    static func == (lhs: EquatableNoop<Value>, rhs: EquatableNoop<Value>) -> Bool { true}
}
