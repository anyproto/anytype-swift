
//
//  CombineExtensin.swift
//  AnyType
//
//  Created by Denis Batvinkin on 26.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

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

// MARK: Publishers Accessors
extension Publisher {
    func successToVoid() -> Publishers.SuccessToVoid<Self> {
        .init(upstream: self)
    }
    func ignoreFailure() -> Publishers.IgnoreFailure<Self> {
        .init(upstream: self)
    }
}

// MARK: AnyPublisher extensions
extension AnyPublisher {
    static func empty() -> AnyPublisher<Self.Output, Self.Failure> {
        Empty<Self.Output, Self.Failure>().eraseToAnyPublisher()
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
