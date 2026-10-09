import Foundation
import ProtobufMessages
@testable import Anytype

final class FakeDNSServiceOperation: DNSServiceOperation {

    private let onCancel: () -> Void
    private(set) var isCancelled = false

    init(onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }

    func cancel() {
        guard !isCancelled else { return }
        isCancelled = true
        onCancel()
    }
}

final class FakeRegistration {
    let name: String
    let type: String
    let domain: String
    let port: UInt16
    let handler: (DNSServiceRegisterEvent) -> Void
    let operation: FakeDNSServiceOperation

    init(name: String, type: String, domain: String, port: UInt16, handler: @escaping (DNSServiceRegisterEvent) -> Void, operation: FakeDNSServiceOperation) {
        self.name = name
        self.type = type
        self.domain = domain
        self.port = port
        self.handler = handler
        self.operation = operation
    }
}

final class FakeBrowse {
    let type: String
    let domain: String
    let handler: (Result<DNSServiceBrowseEvent, DNSServiceError>) -> Void
    let operation: FakeDNSServiceOperation

    init(type: String, domain: String, handler: @escaping (Result<DNSServiceBrowseEvent, DNSServiceError>) -> Void, operation: FakeDNSServiceOperation) {
        self.type = type
        self.domain = domain
        self.handler = handler
        self.operation = operation
    }

    func add(_ name: String, interface: UInt32) {
        handler(.success(DNSServiceBrowseEvent(isAdded: true, interfaceIndex: interface, name: name, type: "_anytype._tcp.", domain: "local.")))
    }

    func remove(_ name: String, interface: UInt32) {
        handler(.success(DNSServiceBrowseEvent(isAdded: false, interfaceIndex: interface, name: name, type: "_anytype._tcp.", domain: "local.")))
    }

    func fail(_ code: Int32) {
        handler(.failure(DNSServiceError(code: code)))
    }
}

final class FakeResolve {
    let name: String
    let interfaceIndex: UInt32
    let handler: (Result<DNSServiceResolveEvent, DNSServiceError>) -> Void
    let operation: FakeDNSServiceOperation

    init(name: String, interfaceIndex: UInt32, handler: @escaping (Result<DNSServiceResolveEvent, DNSServiceError>) -> Void, operation: FakeDNSServiceOperation) {
        self.name = name
        self.interfaceIndex = interfaceIndex
        self.handler = handler
        self.operation = operation
    }

    func resolve(host: String, port: Int) {
        handler(.success(DNSServiceResolveEvent(hostTarget: host, port: port)))
    }

    func fail(_ code: Int32) {
        handler(.failure(DNSServiceError(code: code)))
    }
}

final class FakeLookup {
    let hostname: String
    let interfaceIndex: UInt32
    let handler: (Result<DNSServiceAddressEvent, DNSServiceError>) -> Void
    let operation: FakeDNSServiceOperation

    init(hostname: String, interfaceIndex: UInt32, handler: @escaping (Result<DNSServiceAddressEvent, DNSServiceError>) -> Void, operation: FakeDNSServiceOperation) {
        self.hostname = hostname
        self.interfaceIndex = interfaceIndex
        self.handler = handler
        self.operation = operation
    }

    func add(_ address: String) {
        handler(.success(DNSServiceAddressEvent(isAdded: true, address: address)))
    }

    func remove(_ address: String) {
        handler(.success(DNSServiceAddressEvent(isAdded: false, address: address)))
    }
}

final class FakeDNSServiceClient: DNSServiceClientProtocol {

    private(set) var registrations: [FakeRegistration] = []
    private(set) var browses: [FakeBrowse] = []
    private(set) var resolves: [FakeResolve] = []
    private(set) var lookups: [FakeLookup] = []
    /// Operation kinds in the order they were cancelled.
    private(set) var cancellations: [String] = []

    var registerStartError: DNSServiceError?
    var browseStartError: DNSServiceError?
    var resolveStartError: DNSServiceError?
    var lookupStartError: DNSServiceError?

    var activeRegistrations: [FakeRegistration] { registrations.filter { !$0.operation.isCancelled } }
    var activeBrowses: [FakeBrowse] { browses.filter { !$0.operation.isCancelled } }
    var activeResolves: [FakeResolve] { resolves.filter { !$0.operation.isCancelled } }
    var activeLookups: [FakeLookup] { lookups.filter { !$0.operation.isCancelled } }

    var browse: FakeBrowse? { activeBrowses.last }

    func resolve(_ name: String, interface: UInt32) -> FakeResolve? {
        activeResolves.last(where: { $0.name == name && $0.interfaceIndex == interface })
    }

    func lookup(_ hostname: String, interface: UInt32) -> FakeLookup? {
        activeLookups.last(where: { $0.hostname == hostname && $0.interfaceIndex == interface })
    }

    func register(
        name: String,
        type: String,
        domain: String,
        port: UInt16,
        handler: @escaping (DNSServiceRegisterEvent) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError> {
        if let registerStartError { return .failure(registerStartError) }
        let operation = makeOperation("register")
        registrations.append(FakeRegistration(name: name, type: type, domain: domain, port: port, handler: handler, operation: operation))
        return .success(operation)
    }

    func browse(
        type: String,
        domain: String,
        handler: @escaping (Result<DNSServiceBrowseEvent, DNSServiceError>) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError> {
        if let browseStartError { return .failure(browseStartError) }
        let operation = makeOperation("browse")
        browses.append(FakeBrowse(type: type, domain: domain, handler: handler, operation: operation))
        return .success(operation)
    }

    func resolve(
        name: String,
        type: String,
        domain: String,
        interfaceIndex: UInt32,
        handler: @escaping (Result<DNSServiceResolveEvent, DNSServiceError>) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError> {
        if let resolveStartError { return .failure(resolveStartError) }
        let operation = makeOperation("resolve")
        resolves.append(FakeResolve(name: name, interfaceIndex: interfaceIndex, handler: handler, operation: operation))
        return .success(operation)
    }

    func lookupIPv4(
        hostname: String,
        interfaceIndex: UInt32,
        handler: @escaping (Result<DNSServiceAddressEvent, DNSServiceError>) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError> {
        if let lookupStartError { return .failure(lookupStartError) }
        let operation = makeOperation("lookup")
        lookups.append(FakeLookup(hostname: hostname, interfaceIndex: interfaceIndex, handler: handler, operation: operation))
        return .success(operation)
    }

    private func makeOperation(_ kind: String) -> FakeDNSServiceOperation {
        FakeDNSServiceOperation { [weak self] in
            self?.cancellations.append(kind)
        }
    }
}

final class FakeScheduledWork: LocalDiscoveryCancellable {
    let deadline: TimeInterval
    let sequence: Int
    let work: @Sendable () -> Void
    private(set) var isCancelled = false

    init(deadline: TimeInterval, sequence: Int, work: @escaping @Sendable () -> Void) {
        self.deadline = deadline
        self.sequence = sequence
        self.work = work
    }

    func cancel() {
        isCancelled = true
    }
}

/// A manual clock: scheduled work runs only from `advance(by:)`, in deadline order.
final class FakeLocalDiscoveryScheduler: LocalDiscoverySchedulerProtocol {

    private(set) var now: TimeInterval = 0
    private var scheduled: [FakeScheduledWork] = []
    private var sequence = 0

    var pendingDelays: [TimeInterval] {
        scheduled.filter { !$0.isCancelled }.map { $0.deadline - now }
    }

    func schedule(after delay: TimeInterval, _ work: @escaping @Sendable () -> Void) -> any LocalDiscoveryCancellable {
        sequence += 1
        let item = FakeScheduledWork(deadline: now + delay, sequence: sequence, work: work)
        scheduled.append(item)
        return item
    }

    func advance(by interval: TimeInterval) {
        let target = now + interval
        while let next = scheduled
            .filter({ !$0.isCancelled && $0.deadline <= target + 0.000_001 })
            .min(by: { ($0.deadline, $0.sequence) < ($1.deadline, $1.sequence) }) {
            scheduled.removeAll { $0 === next }
            now = max(now, next.deadline)
            next.work()
        }
        scheduled.removeAll { $0.isCancelled }
        now = target
    }
}

struct FakeObservedChange: Equatable {
    let peerId: String
    let addresses: [String]
    let port: Int
}

final class FakeLocalDiscoveryObserver: LocalDiscoveryObserver, @unchecked Sendable {

    let port: Int
    let peerId: String
    let serviceType = "_anytype._tcp"

    private(set) var changes: [FakeObservedChange] = []
    private(set) var lost: [String] = []
    private(set) var errors: [Int] = []

    init(peerId: String = "self-peer", port: Int = 62654) {
        self.peerId = peerId
        self.port = port
    }

    func observeChange(peerId: String, addresses: [String], port: Int) {
        changes.append(FakeObservedChange(peerId: peerId, addresses: addresses, port: port))
    }

    func observeLost(peerId: String) {
        lost.append(peerId)
    }

    func observeError(code: Int, message: String) {
        errors.append(code)
    }
}
