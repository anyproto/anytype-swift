import Foundation

extension AsyncStream {
    static func task(@_inheritActorContext @_implicitSelfCapture _ operation: @Sendable @escaping @isolated(any) (_ iterator: (Element) -> Void) async -> Void)
    -> AsyncStream<Element> where Element: Sendable {
        
        return AsyncStream { continuation in
            let task = Task {
                await operation { element in
                    continuation.yield(element)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
