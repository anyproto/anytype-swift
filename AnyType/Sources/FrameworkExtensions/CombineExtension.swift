
//
//  CombineExtensin.swift
//  AnyType
//
//  Created by Denis Batvinkin on 26.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

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
    /// A publisher that ignores error and return Empty<Ouptut, Never> subscriber instead which **finishes immediately**.
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

// MARK: NotableError
extension Publishers {
    /// A publisher that takes attention to failure type and change Publisher.Failure from Never to Error.
    /// Actually, it is `.mapError(f)` where `f: (Failure) -> (Error)`
    public struct NotableError<Upstream> : Publisher where Upstream : Publisher, Upstream.Failure == Never {
        /// Private structure which adopts generic protocol Error. It is required for changing type of error.
        private struct UnbelievableError: Error {}
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Void` if this `Publisher` does not publish errors.
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        private let downstream: Publishers.MapError<Upstream, Failure>
        public init(upstream: Upstream) {
            self.upstream = upstream
            self.downstream = upstream.mapError({_ in UnbelievableError()})
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
    public struct SafelyUnwrapOptionals<T, Upstream> : Publisher where Upstream : Publisher, Upstream.Output == Optional<T> {
        /// The kind of values published by this publisher.
        public typealias Output = T

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Void` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        private let downstream: FlatMap<AnyPublisher<Output, Failure>, Publishers.Filter<Upstream>>
        
        public init(upstream: Upstream) {
            self.upstream = upstream
            
//            self.downstream = upstream.filter{$0 != nil}.flatMap { (value) -> AnyPublisher<Output, Failure> in
//                guard let value = value else { return .empty() }
//                return CurrentValueSubject(value).eraseToAnyPublisher()
//            }
            
            self.downstream = upstream.filter{$0 != nil}.flatMap({ $0.flatMap(CurrentValueSubject.init).map{$0.eraseToAnyPublisher()} ?? .empty() })
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
}

extension Publisher where Self.Failure == Never {
    func notableError() -> Publishers.NotableError<Self> {
        .init(upstream: self)
    }
}

// MARK: AnyPublisher extensions
extension AnyPublisher {
    static func empty() -> AnyPublisher<Output, Failure> {
        Empty().eraseToAnyPublisher()
    }
}

// MARK: AnyCancellable convenient cancel
extension Set where Element == AnyCancellable {
    /// Convenient method to cancel all subscriptions in Set.
    ///
    /// NOTE: You should add Sequence or Collection extension to apply this method to other available collection storage of Combine.
    func cancelAll() {
        self.forEach({$0.cancel()})
    }
}
