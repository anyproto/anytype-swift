import Foundation
import Combine

// MARK: PublisherAndSubjectPair
extension Publishers {
    class WriteableStream<Success, Failure> where Failure: Error {
        private var subject: PassthroughSubject<Success, Failure> = .init()
        private(set) var publisher: AnyPublisher<Success, Failure> = .empty()
        init() {
            self.publisher = self.subject.eraseToAnyPublisher()
        }
        func send(_ value: Success) {
            self.subject.send(value)
        }
    }
}

// MARK: SuccessToVoid
extension Publishers {
    
    /// A publisher that ignores all upstream elements and map success to void, but passes along a completion state (finish or failed).
    ///
    /// Discussion
    ///
    /// Consider next situation. You have a publisher with some output.
    /// You would like to work with this publisher and you would like to ignore the result value of this publisher.
    /// You have two options now.
    ///
    /// 1. IgnoreOutput :: Self.Output -> Never
    /// 2. SuccessToVoid :: Self.Output -> Void
    ///
    /// `IgnoreOutput` will *really* ignore output all output values and you can't use it with `.flatMap` for chaining.
    /// `SuccessToVoid` will *erase* all output to void and you can use all output transforms without a hassle.
    ///
    public struct SuccessToVoid<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Void
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Void` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        private let downstream: Map<Upstream, Output>
        public init(upstream: Upstream) {
            self.upstream = upstream
            self.downstream = self.upstream.map({_ in ()})
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Publishers.SuccessToVoid<Upstream>.Output {
            self.downstream.receive(subscriber: subscriber)
        }
    }
}

// MARK: IgnoreError
extension Publishers {
    /// A publisher that ignores error and return Empty<Ouptut, Never> publisher instead which completes **immediately**
    ///
    /// Workaround
    ///
    /// If you want non-ending stream with error handling, please, do the following trick.
    ///
    /// ```
    /// .flatMap { (input) in Just(input).map().ignoreFailure() }
    /// ```
    ///
    public struct IgnoreFailure<Upstream> : Publisher where Upstream : Publisher {
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Void` if this `Publisher` does not publish errors.
        public typealias Failure = Never
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        private let downstream: Catch<Upstream, Empty<Output, Failure>>
        public init(upstream: Upstream) {
            self.upstream = upstream
            self.downstream = upstream.catch({_ in Empty<Output, Failure>()})
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
}

// MARK: SafelyUnwrapOptionals
extension Publishers {
    /// A publisher that ignores nil values and safely unwrap optionals.
    ///
    /// Discussion
    ///
    /// Unlike `TryMap` this publisher is applied only for Outputs which are `Optional`.
    ///
    public struct SafelyUnwrapOptionals<T, Upstream> : Publisher where Upstream : Publisher, Upstream.Output == Optional<T> {
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
            self.downstream = upstream.filter { !$0.isNil }.map { $0! }
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
}

// MARK: Publishers Accessors
extension Publisher {
    func safelyUnwrapOptionals<T>() -> Publishers.SafelyUnwrapOptionals<T, Self> {
        .init(upstream: self)
    }
    func successToVoid() -> Publishers.SuccessToVoid<Self> {
        .init(upstream: self)
    }
    func ignoreFailure() -> Publishers.IgnoreFailure<Self> {
        .init(upstream: self)
    }
    func receiveOnMain() -> Publishers.ReceiveOn<Self, DispatchQueue> {
        return self.receive(on: DispatchQueue.main)
    }
}

extension Publisher where Self.Failure == Never {
    func notableError() -> Publishers.SetFailureType<Self, Error> {
        self.setFailureType(to: Error.self)
    }
}

// MARK: AnyPublisher extensions
extension AnyPublisher {
    static func empty() -> Self<Output, Failure> { Empty().eraseToAnyPublisher() }
}

