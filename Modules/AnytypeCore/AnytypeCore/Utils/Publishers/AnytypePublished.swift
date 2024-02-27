import Foundation
import Combine

struct AnytypePassthroughSubject<Value: Equatable> {
    var value: Value
    var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }
    private var subject = PassthroughSubject<Value, Never>()
    
    init(_ value: Value) {
        self.value = value
    }
    
    func sendUpdate() {
        subject.send(value)
    }
}
