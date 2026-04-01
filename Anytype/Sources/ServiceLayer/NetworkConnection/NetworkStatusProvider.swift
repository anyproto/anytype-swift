import Foundation
import Network
import Factory
import Combine

protocol NetworkStatusProviderProtocol: AnyObject, Sendable {
    var isConnected: Bool { get }
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
}

final class NetworkStatusProvider: NetworkStatusProviderProtocol, @unchecked Sendable {

    private let monitor = NWPathMonitor()
    private let subject = CurrentValueSubject<Bool, Never>(true)

    var isConnected: Bool { subject.value }

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        subject.removeDuplicates().eraseToAnyPublisher()
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.subject.send(path.status == .satisfied)
        }
        monitor.start(queue: .main)
    }

    deinit {
        monitor.cancel()
    }
}
