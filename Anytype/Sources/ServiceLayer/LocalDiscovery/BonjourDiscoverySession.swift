import Foundation
import AnytypeCore
import ProtobufMessages

/// One run of the engine, from start to stop: its DNS-SD operations and everything learned meanwhile.
/// Confined to the discovery queue, like the engine.
final class BonjourDiscoverySession {

    let id: Int
    /// The engine's scene activation count when this session started.
    let activation: Int
    let observer: any LocalDiscoveryObserver

    var registration: (any DNSServiceOperation)?
    var pendingRegistration: (any LocalDiscoveryCancellable)?
    var nameConflictRetries = 0
    var browse: (any DNSServiceOperation)?

    var peers: [String: BonjourDiscoveredPeer] = [:]
    var pendingReports: [String: any LocalDiscoveryCancellable] = [:]
    /// Peers middleware has heard about: only these can be reported lost.
    var reportedPeers: Set<String> = []
    /// What middleware last heard about each peer, cleared while the peer has no reachable address
    /// so that its return is reported again.
    var lastReports: [String: BonjourPeerReport] = [:]

    private var instanceCounter = 0

    init(id: Int, activation: Int, observer: any LocalDiscoveryObserver) {
        self.id = id
        self.activation = activation
        self.observer = observer
    }

    func makeInstance(interfaceIndex: UInt32, type: String, domain: String) -> BonjourPeerInstance {
        instanceCounter += 1
        return BonjourPeerInstance(id: instanceCounter, interfaceIndex: interfaceIndex, type: type, domain: domain)
    }
}

/// A peer seen by the browse, on one or more interfaces.
final class BonjourDiscoveredPeer {

    private(set) var instances: [UInt32: BonjourPeerInstance] = [:]
    /// Interfaces in the order the peer was first seen on them.
    private var interfaceOrder: [UInt32] = []

    func add(_ instance: BonjourPeerInstance) {
        instances[instance.interfaceIndex] = instance
        if !interfaceOrder.contains(instance.interfaceIndex) {
            interfaceOrder.append(instance.interfaceIndex)
        }
    }

    func removeInstance(interfaceIndex: UInt32) -> BonjourPeerInstance? {
        interfaceOrder.removeAll { $0 == interfaceIndex }
        return instances.removeValue(forKey: interfaceIndex)
    }

    /// The union of the peer's addresses across interfaces, first-seen interface first. The port comes
    /// from the first interface with addresses; interfaces resolved to another port are left out.
    var report: BonjourPeerReport? {
        let reachable = interfaceOrder.compactMap { instances[$0] }.filter { $0.addresses.isNotEmpty && $0.port.isNotNil }
        guard let port = reachable.first?.port else { return nil }
        var addresses: [String] = []
        for address in reachable.filter({ $0.port == port }).flatMap(\.addresses) where !addresses.contains(address) {
            addresses.append(address)
        }
        return BonjourPeerReport(addresses: addresses, port: port)
    }
}

/// A peer's service instance on one interface, with its resolve and address lookup.
final class BonjourPeerInstance {

    let id: Int
    let interfaceIndex: UInt32
    let type: String
    let domain: String

    var resolve: (any DNSServiceOperation)?
    var addressLookup: (any DNSServiceOperation)?
    var hostTarget: String?
    var port: Int?
    var addresses: [String] = []

    init(id: Int, interfaceIndex: UInt32, type: String, domain: String) {
        self.id = id
        self.interfaceIndex = interfaceIndex
        self.type = type
        self.domain = domain
    }

    var isResolving: Bool {
        resolve.isNotNil
    }

    func reset() {
        resolve?.cancel()
        resolve = nil
        addressLookup?.cancel()
        addressLookup = nil
        hostTarget = nil
        port = nil
        addresses = []
    }
}

struct BonjourPeerReport: Equatable {
    let addresses: [String]
    let port: Int
}
