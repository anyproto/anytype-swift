
//
//  CombineExtensin.swift
//  AnyType
//
//  Created by Denis Batvinkin on 26.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

extension Publishers {

    /// A publisher that ignores all upstream elements, but passes along a completion state (finish or failed).
    public struct SuccessToVoid<Upstream> : Publisher where Upstream : Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Void

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public init(upstream: Upstream) {
            self.upstream = upstream
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Publishers.SuccessToVoid<Upstream>.Output {
            self.upstream.map({_ in Void()}).receive(subscriber: subscriber)
        }
    }
}

extension Publisher {
    func successToVoid() -> Publishers.SuccessToVoid<Self> {
        .init(upstream: self)
    }
}
