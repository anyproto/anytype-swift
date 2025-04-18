import Combine

struct AsyncSequencePublisher<Upstream: AsyncSequence>: Publisher {

    typealias Output = Upstream.Element
    typealias Failure = Error

    private let sequence: Upstream

    init(_ sequence: Upstream) {
        self.sequence = sequence
    }

    func receive<S>(subscriber: S) where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        let subscription = AsyncSequenceSubscription(subscriber: subscriber, sequence: sequence)
        subscriber.receive(subscription: subscription)
    }
}

private final class AsyncSequenceSubscription<Upstream: AsyncSequence, S: Subscriber>: Subscription,
    @unchecked Sendable where S.Input == Upstream.Element, S.Failure == Error
{
    private let sequence: Upstream
    private var subscriber: S?
    private var task: Task<Void, Never>?

    init(subscriber: S, sequence: Upstream) {
        self.sequence = sequence
        self.subscriber = subscriber

        task = Task.detached { [weak self]  in
            do {
                var iterator = self?.sequence.makeAsyncIterator()
                while let element = try await iterator?.next() {
                    _ = self?.subscriber?.receive(element)
                }
                self?.subscriber?.receive(completion: .finished)
            } catch {
                self?.subscriber?.receive(completion: .failure(error))
            }
        }
    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
        task?.cancel()
        task = nil
        subscriber = nil
    }
}

extension AsyncSequence {
    public func publisher() -> some Publisher<Element, Error> {
        AsyncSequencePublisher(self)
    }
}
