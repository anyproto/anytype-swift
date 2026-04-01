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

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.subject.send(path.status == .satisfied)
            }
        }
        monitor.start(queue: .main)
    }

    deinit {
        monitor.cancel()
    }
}
