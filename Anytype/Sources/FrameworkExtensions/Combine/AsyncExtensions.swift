import Foundation
import Combine

// Source: https://trycombine.com/posts/combine-async-sequence-2/
// TODO: Delete from ios 15. Use $field.values

struct MyAsyncPublisher<P> : AsyncSequence where P : Publisher, P.Failure == Never  {
    typealias Element = P.Output
    typealias AsyncIterator = AsyncStream<P.Output>.AsyncIterator

    var upstream: P
    
    init(_ upstream: P) {
        self.upstream = upstream
    }

    func makeAsyncIterator() -> AsyncStream<Element>.AsyncIterator {
        var subscription : Subscription?

        let stream = AsyncStream<Element> { continuation in
            let mySubscriber = AnySubscriber<Element, Never>(
                receiveSubscription: { s in subscription = s; s.request(.max(1)) },
                receiveValue: { continuation.yield($0); return .max(1) },
                receiveCompletion:  { _ in continuation.finish(); subscription?.cancel() })
            
            self.upstream.receive(subscriber: mySubscriber)
        }
        
        return stream.makeAsyncIterator()
    }
}

extension Publisher where Failure == Never {
    var myValues : MyAsyncPublisher<Self> {
        MyAsyncPublisher<Self>(self)
    }
}
