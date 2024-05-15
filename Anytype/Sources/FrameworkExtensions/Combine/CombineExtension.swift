import Foundation
import Combine


struct SafelyUnwrapOptionals<T, Upstream> : Publisher where Upstream : Publisher, Upstream.Output == Optional<T> {
    /// The kind of values published by this publisher.
    public typealias Output = T
    
    /// The kind of errors this publisher might publish.
    ///
    /// Use `Void` if this `Publisher` does not publish errors.
    public typealias Failure = Upstream.Failure
    
    /// The publisher from which this publisher receives elements.
    public let upstream: Upstream
    private let downstream: Publishers.Map<Publishers.Filter<Upstream>, T> //FlatMap<AnyPublisher<Output, Failure>, Publishers.Filter<Upstream>>
    
    public init(upstream: Upstream) {
        self.upstream = upstream
        self.downstream = upstream.filter { $0.isNotNil }.map { $0! }
    }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
        self.downstream.receive(subscriber: subscriber)
    }
}

// MARK: Publishers Accessors
extension Publisher {
    func safelyUnwrapOptionals<T>() -> SafelyUnwrapOptionals<T, Self> {
        .init(upstream: self)
    }
    func receiveOnMain() -> Publishers.ReceiveOn<Self, DispatchQueue> {
        return self.receive(on: DispatchQueue.main)
    }
}

extension Publisher where Self.Failure == Never {
    // receiveOnMain always call on main thread asynchronyously.
    // If we subscribe from main thread on view, async call can make empty view state. User can see ugly updates.
    // This method call on main thread synchronyously if current thread is main.
    func sinkOnMain(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        if Thread.isMainThread {
            return self.sink(receiveValue: receiveValue)
        } else {
            return self
                .receiveOnMain()
                .sink(receiveValue: receiveValue)
        }
    }
}

// MARK: AnyPublisher extensions
extension AnyPublisher {
    static func empty() -> AnyPublisher<Output, Failure> { Empty().eraseToAnyPublisher() }
}
