import Foundation

extension AsyncSequence where Self: Sendable {
    // Temporary fix. Issue https://github.com/apple/swift-async-algorithms/issues/266
    public func throttle(milliseconds: Int, latest: Bool = true) -> AnyAsyncSequence<Element> {
        self
            .publisher()
            .throttle(for: .milliseconds(milliseconds), scheduler: DispatchQueue.global(), latest: latest)
            .values
            .eraseToAnyAsyncSequence()
    }
}
