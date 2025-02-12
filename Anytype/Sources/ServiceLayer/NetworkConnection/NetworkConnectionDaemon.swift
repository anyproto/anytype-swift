import Foundation
import ProtobufMessages
import Network


// Monitors network connection and sends it to middleware
protocol NetworkConnectionStatusDaemonProtocol: Sendable {
    func start() async
    func stop() async
}

final class NetworkConnectionStatusDaemon: NetworkConnectionStatusDaemonProtocol, Sendable {
    private let nwPathMonitor = NWPathMonitor()
    
    nonisolated init() { }
    
    func start() async {
        setup()
        nwPathMonitor.start(queue: .main)
    }
    
    func stop() async {
        nwPathMonitor.cancel()
    }
    
    private func setup() {
        nwPathMonitor.pathUpdateHandler = { path in
            let networkType: Anytype_Model_DeviceNetworkType
            
            switch path.status {
            case .satisfied:
                if path.usesInterfaceType(.wifi) {
                    networkType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    networkType = .cellular
                } else {
                    networkType = .wifi // fallback
                }
            case .requiresConnection, .unsatisfied:
                networkType = .notConnected
            @unknown default:
                networkType = .notConnected
            }
            
            Task {
                try await ClientCommands.deviceNetworkStateSet(.with {
                    $0.deviceNetworkType = networkType
                }).invoke()
            }
        }
    }
}

extension Container {
    var networkConnectionStatusDaemon: Factory<any NetworkConnectionStatusDaemonProtocol> {
        self { NetworkConnectionStatusDaemon() }.singleton
    }
}
