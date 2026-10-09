import Foundation

protocol LocalDiscoveryCancellable: AnyObject {
    func cancel()
}

protocol LocalDiscoverySchedulerProtocol: AnyObject {
    func schedule(after delay: TimeInterval, _ work: @escaping @Sendable () -> Void) -> any LocalDiscoveryCancellable
}

final class DispatchQueueLocalDiscoveryScheduler: LocalDiscoverySchedulerProtocol {

    private let queue: DispatchQueue

    init(queue: DispatchQueue) {
        self.queue = queue
    }

    func schedule(after delay: TimeInterval, _ work: @escaping @Sendable () -> Void) -> any LocalDiscoveryCancellable {
        let item = DispatchWorkItem(block: work)
        queue.asyncAfter(deadline: .now() + delay, execute: item)
        return item
    }
}

extension DispatchWorkItem: LocalDiscoveryCancellable {}
