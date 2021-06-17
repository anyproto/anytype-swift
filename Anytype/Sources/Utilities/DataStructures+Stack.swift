//
//  DataStructures+Stack.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.01.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = DataStructures

extension Namespace {
    typealias Stack = _ClassStack
}

extension Namespace {
    /// Stack implementation as Class.
    ///
    /// TODO:
    /// Add implementation for `Struct` if needed.
    ///
    /// Discussion
    /// Actually, we need different initializations for a outer `Stack` to choose between `Class` or `Struct`.
    ///
    class _ClassStack<T> {
        private var list: [T] = []
        init(_ element: T) {
            self.list.append(element)
        }
        init(_ elements: [T] = []) {
            self.list = elements
        }
        func push(_ element: T) {
            self.list.append(element)
        }
        func peek() -> T? {
            self.list.last
        }
        func pop() -> T? {
            guard !self.isEmpty else { return nil }
            let element = self.list.removeLast()
            return element
        }
        var isEmpty: Bool {
            self.list.isEmpty
        }
        func unsafePop() -> T {
            self.pop()!
        }
        func unsafePeek() -> T {
            self.peek()!
        }
    }
}
