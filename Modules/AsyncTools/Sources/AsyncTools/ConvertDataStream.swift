import Foundation
import AsyncAlgorithms

public extension AsyncStream {
    
    static func convertData<S: AsyncSequence>(_ stream: S, @_implicitSelfCapture _ value: @Sendable @escaping @isolated(any) () async -> Element?)
    -> AsyncStream<Element> where Element: Sendable, S: Sendable {
        AsyncStream<Element>.task { iterator in
            // TODO: When we will set minimum ios to 18, add S.Failure == Never and remove eraseToAnyAsyncSequence
            for await _ in stream.eraseToAnyAsyncSequence() {
                if let data = await value() {
                    iterator(data)
                }
            }
        }
    }
}
