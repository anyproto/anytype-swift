import Foundation
import ProtobufMessages
import Network
import AnytypeCore
import Logger


// Monitors network connection and sends it to middleware
protocol NetworkConnectionStatusDaemonProtocol: Sendable {
    func start() async
    func stop() async
}

actor NetworkConnectionStatusDaemon: NetworkConnectionStatusDaemonProtocol {

    private static let log = EventLogger(category: "NetworkConnectionStatusDaemon")

    private let monitorQueue = DispatchQueue(label: "io.anytype.netmonitor")
    private var nwPathMonitor: NWPathMonitor?
    private var pathContinuation: AsyncStream<NWPath>.Continuation?
    private var reportingTask: Task<Void, Never>?

    init() { }

    func start() async {
        guard nwPathMonitor.isNil else { return }

        // cancel() is terminal for NWPathMonitor, so every start needs a new instance.
        let monitor = NWPathMonitor()
        let (paths, continuation) = AsyncStream<NWPath>.makeStream(bufferingPolicy: .unbounded)

        // Middleware coalesces bursts itself and treats duplicates as no-ops, so every callback is
        // reported without debounce. Reports go through one task because invocations run on a
        // concurrent queue: parallel tasks could leave middleware holding a stale path as the last seen one.
        reportingTask = Task {
            for await path in paths {
                await Self.report(path: path)
            }
        }

        monitor.pathUpdateHandler = { continuation.yield($0) }
        monitor.start(queue: monitorQueue)

        nwPathMonitor = monitor
        pathContinuation = continuation
    }

    func stop() async {
        nwPathMonitor?.cancel()
        nwPathMonitor = nil
        pathContinuation?.finish()
        pathContinuation = nil

        // invoke() is uncancellable, so a report in flight during stop() would otherwise outlive this
        // session and race the next session's reports on the concurrent RPC queue, landing a stale path
        // last. cancel() stops draining buffered paths; awaiting value lets the in-flight report finish
        // before stop() returns. Detach from the stored property first so a re-entrant start() isn't cleared.
        let task = reportingTask
        reportingTask = nil
        task?.cancel()
        await task?.value
    }

    // MARK: - Private

    private static func report(path: NWPath) async {
        let networkType = path.deviceNetworkType
        let networkId = path.networkId

        log.debug("Reporting network state", metadata: ["type": "\(networkType)", "networkId": networkId])

        _ = try? await ClientCommands.deviceNetworkStateSet(.with {
            $0.deviceNetworkType = networkType
            $0.networkID = networkId
        }).invoke()
    }
}

private extension NWPath {

    var deviceNetworkType: Anytype_Model_DeviceNetworkType {
        switch status {
        case .satisfied:
            // Cellular takes precedence when a path uses both interface types, matching the
            // integration guide and Android. Everything else satisfied (wi-fi, wired, other) is wifi.
            return usesInterfaceType(.cellular) ? .cellular : .wifi
        case .requiresConnection, .unsatisfied:
            return .notConnected
        @unknown default:
            return .notConnected
        }
    }

    // Opaque identity of the path. The type enum can't express a same-type switch (Wi-Fi to Wi-Fi),
    // which middleware needs to see to reset connections and re-sync instead of waiting out transport timeouts.
    var networkId: String {
        guard status == .satisfied else { return "" }

        let interfaceNames = availableInterfaces.map(\.name).sorted().joined(separator: ",")
        let gatewayNames = gateways.map { "\($0)" }.sorted().joined(separator: ",")
        return interfaceNames + "|" + gatewayNames
    }
}

extension Container {
    var networkConnectionStatusDaemon: Factory<any NetworkConnectionStatusDaemonProtocol> {
        self { NetworkConnectionStatusDaemon() }.singleton
    }
}
