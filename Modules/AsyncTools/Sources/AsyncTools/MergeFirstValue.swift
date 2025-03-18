import Foundation
import AsyncAlgorithms

public func mergeFirstValue<S: AsyncSequence, V>(_ stream: S, _ firstValue: V) -> AnyAsyncSequence<S.Element>
where S.Element: Collection, S.Element: Sendable, V == S.Element, S.Element.Element: Equatable, S: Sendable {
    merge(stream, [firstValue].async)
        .filter { values in values.contains { value in firstValue.contains(value) } }
        .eraseToAnyAsyncSequence()
}
