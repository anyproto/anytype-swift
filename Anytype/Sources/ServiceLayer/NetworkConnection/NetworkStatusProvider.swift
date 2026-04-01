import Foundation
import Network
import Factory
import Combine

@MainActor
protocol NetworkStatusProviderProtocol: AnyObject {
    var isConnected: Bool { get }
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
}

@MainActor
final class NetworkStatusProvider: NetworkStatusProviderProtocol {

    private let monitor = NWPathMonitor()
    private let subject = CurrentValueSubject<Bool, Never>(true)

    var isConnected: Bool { subject.value }

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        subject.removeDuplicates().eraseToAnyPublisher()
    }

    nonisolated init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.subject.send(path.status == .satisfied)
            }
        }
        monitor.start(queue: DispatchQueue(label: "network-monitor"))
    }

    deinit {
        monitor.cancel()
    }
}
