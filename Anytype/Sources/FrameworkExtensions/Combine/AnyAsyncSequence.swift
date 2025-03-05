import AsyncAlgorithms

extension AsyncSequence {
    func eraseToAnyAsyncSequence() -> AnyAsyncSequence<Element> {
        AnyAsyncSequence(wrapping: self)
    }
}

// Source - https://github.com/apple/swift-nio/blob/56f9b7c6fc9525ba36236dbb151344f8c35288df/Sources/NIOFileSystem/Internal/BufferedOrAnyStream.swift#L72
struct AnyAsyncSequence<Element>: AsyncSequence {
    private let _makeAsyncIterator: () -> AsyncIterator
    
    init<S: AsyncSequence>(wrapping sequence: S) where S.Element == Element {
        self._makeAsyncIterator = {
            AsyncIterator(wrapping: sequence.makeAsyncIterator())
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        self._makeAsyncIterator()
    }

    struct AsyncIterator: AsyncIteratorProtocol {
        private var iterator: any AsyncIteratorProtocol

        init<I: AsyncIteratorProtocol>(wrapping iterator: I) where I.Element == Element {
            self.iterator = iterator
        }

        mutating func next() async -> Element? {
            try? await self.iterator.next() as? Element
        }
    }
}
