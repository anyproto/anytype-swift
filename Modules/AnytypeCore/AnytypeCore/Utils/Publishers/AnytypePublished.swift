import Foundation
import Combine

struct AnytypePublished<Value> {
    
    private var subject: CurrentValueSubject<Value, Never>
    
    var value: Value {
        get { return subject.value }
        set { subject.send(newValue) }
    }
    
    init(_ value: Value) {
        self.subject = CurrentValueSubject(value)
    }
    
    var publisher: AnyPublisher<Value, Never> {
        return subject.eraseToAnyPublisher()
    }
}
