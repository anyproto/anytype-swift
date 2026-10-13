import Foundation
import AnytypeCore
import ProtobufMessages
import os

/// LAN discovery over the system DNS-SD for middleware's `LocalDiscoveryObserver`: registers our
/// peer, browses for others and reports them. Runs only while an observer is set and the app is in
/// the foreground. Confined to one serial queue: every call, DNS-SD handler and scheduled work runs on it.
final class BonjourDiscoveryEngine: @unchecked Sendable {

    static let domain = "local."
    static let reportDebounce: TimeInterval = 0.25
    static let nameConflictRetryDelay: TimeInterval = 5
    static let nameConflictRetryLimit = 3
    static let maxRestartDelay: TimeInterval = 30

    private static let log = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "io.anytype", category: "LocalDiscovery")

    private let client: any DNSServiceClientProtocol
    private let scheduler: any LocalDiscoverySchedulerProtocol

    private var observer: (any LocalDiscoveryObserver)?
    private var isForeground = false
    private var isPolicyDenied = false
    private var session: BonjourDiscoverySession?
    private var sessionCounter = 0
    private var activationCount = 0
    private var restartAttempt = 0
    private var pendingRestart: (any LocalDiscoveryCancellable)?

    init(client: any DNSServiceClientProtocol, scheduler: any LocalDiscoverySchedulerProtocol) {
        self.client = client
        self.scheduler = scheduler
    }

    // MARK: - Inputs

    func setObserver(_ observer: any LocalDiscoveryObserver) {
        self.observer = observer
        // A new observer (account) deserves its own attempt, and its own denial report.
        isPolicyDenied = false
        restartAttempt = 0
        stop()
        startIfNeeded()
    }

    func removeObserver() {
        observer = nil
        stop()
    }

    func setForeground(_ isForeground: Bool) {
        guard self.isForeground != isForeground else { return }
        self.isForeground = isForeground
        // Refs from before a suspension are defunct: every foreground starts from fresh ones.
        stop()
        if isForeground {
            isPolicyDenied = false
            restartAttempt = 0
            startIfNeeded()
        }
    }

    /// The Local Network prompt deactivates the scene while it is shown and may deny operations before
    /// the user answers it. The scene becoming active again (the prompt dismissed) is when to find out
    /// what they chose; a denial arriving later for an earlier session is handled in `handleFatalError`.
    func sceneDidActivate() {
        activationCount += 1
        guard isPolicyDenied else { return }
        isPolicyDenied = false
        startIfNeeded()
    }

    // MARK: - Lifecycle

    private func startIfNeeded() {
        guard let observer, isForeground, !isPolicyDenied, session.isNil else { return }
        sessionCounter += 1
        let session = BonjourDiscoverySession(id: sessionCounter, activation: activationCount, observer: observer)
        self.session = session
        Self.log.info("Start: peer \(observer.peerId, privacy: .public), port \(observer.port)")
        startRegistration(session)
        guard self.session === session else { return }
        startBrowse(session)
    }

    private func stop() {
        pendingRestart?.cancel()
        pendingRestart = nil
        stopSession()
    }

    /// Deallocates the registration first, so mDNSResponder sends the goodbye, then everything else.
    /// Peers cleared here are not reported lost: they did not leave, we stopped looking.
    private func stopSession() {
        guard let session else { return }
        self.session = nil
        session.registration?.cancel()
        session.registration = nil
        session.pendingRegistration?.cancel()
        session.pendingRegistration = nil
        session.browse?.cancel()
        session.browse = nil
        for peer in session.peers.values {
            for instance in peer.instances.values {
                instance.reset()
            }
        }
        session.peers = [:]
        for pendingReport in session.pendingReports.values {
            pendingReport.cancel()
        }
        session.pendingReports = [:]
        Self.log.info("Stop: peer \(session.observer.peerId, privacy: .public)")
    }

    private func activeSession(_ id: Int) -> BonjourDiscoverySession? {
        guard let session, session.id == id else { return nil }
        return session
    }

    private func handleFatalError(_ code: Int32, operation: String, session: BonjourDiscoverySession) {
        Self.log.error("\(operation, privacy: .public) failed: \(code)")
        session.observer.observeError(code: Int(code), message: "\(operation) failed: \(code)")
        stopSession()
        switch code {
        case DNSServiceErrorCode.policyDenied:
            if session.activation < activationCount {
                // The scene activated since this session started: the denial may predate the
                // user's answer to the prompt, so the answer gets one fresh attempt.
                startIfNeeded()
            } else {
                // Denied (or not answered yet): wait for the next activation or foreground, which
                // also covers the user changing it in Settings.
                isPolicyDenied = true
            }
        case DNSServiceErrorCode.serviceNotRunning, DNSServiceErrorCode.defunctConnection:
            scheduleRestart()
        default:
            anytypeAssertionFailure("Local discovery DNS-SD error", info: ["operation": operation, "code": "\(code)"])
            scheduleRestart()
        }
    }

    private func scheduleRestart() {
        let delay = min(Self.maxRestartDelay, TimeInterval(1 << min(restartAttempt, 5)))
        restartAttempt += 1
        Self.log.info("Restart in \(delay)s")
        pendingRestart = scheduler.schedule(after: delay) { [weak self] in
            guard let self else { return }
            pendingRestart = nil
            startIfNeeded()
        }
    }

    // MARK: - Registration

    private func startRegistration(_ session: BonjourDiscoverySession) {
        let observer = session.observer
        guard let port = UInt16(exactly: observer.port), port != 0 else {
            anytypeAssertionFailure("Local discovery: invalid port", info: ["port": "\(observer.port)"])
            return
        }
        let sessionId = session.id
        let result = client.register(name: observer.peerId, type: observer.serviceType, domain: Self.domain, port: port) { [weak self] event in
            guard let self, let session = activeSession(sessionId) else { return }
            handleRegisterEvent(event, session: session)
        }
        switch result {
        case .success(let operation):
            session.registration = operation
        case .failure(let error):
            handleRegistrationError(error.code, session: session)
        }
    }

    private func handleRegisterEvent(_ event: DNSServiceRegisterEvent, session: BonjourDiscoverySession) {
        switch event {
        case .registered(let name):
            if name != session.observer.peerId {
                anytypeAssertionFailure("Local discovery registered under a different name", info: ["name": name])
            }
            Self.log.info("Registered \(name, privacy: .public)")
            session.nameConflictRetries = 0
            restartAttempt = 0
            session.observer.observeError(code: Int(DNSServiceErrorCode.noError), message: "")
        case .withdrawn:
            handleRegistrationError(DNSServiceErrorCode.nameConflict, session: session)
        case .failed(let error):
            handleRegistrationError(error.code, session: session)
        }
    }

    /// A conflict is most likely our own stale record after a quick restart: retry the registration
    /// alone a few times. Any other registration error restarts the engine.
    private func handleRegistrationError(_ code: Int32, session: BonjourDiscoverySession) {
        guard code == DNSServiceErrorCode.nameConflict else {
            handleFatalError(code, operation: "register", session: session)
            return
        }
        session.registration?.cancel()
        session.registration = nil
        Self.log.error("Name conflict for \(session.observer.peerId, privacy: .public)")
        session.observer.observeError(code: Int(code), message: "register: name conflict")
        guard session.nameConflictRetries < Self.nameConflictRetryLimit else { return }
        session.nameConflictRetries += 1
        let sessionId = session.id
        session.pendingRegistration = scheduler.schedule(after: Self.nameConflictRetryDelay) { [weak self] in
            guard let self, let session = activeSession(sessionId) else { return }
            session.pendingRegistration = nil
            startRegistration(session)
        }
    }

    // MARK: - Browse

    private func startBrowse(_ session: BonjourDiscoverySession) {
        let sessionId = session.id
        let result = client.browse(type: session.observer.serviceType, domain: Self.domain) { [weak self] result in
            guard let self, let session = activeSession(sessionId) else { return }
            switch result {
            case .success(let event):
                handleBrowseEvent(event, session: session)
            case .failure(let error):
                handleFatalError(error.code, operation: "browse", session: session)
            }
        }
        switch result {
        case .success(let operation):
            session.browse = operation
        case .failure(let error):
            handleFatalError(error.code, operation: "browse", session: session)
        }
    }

    private func handleBrowseEvent(_ event: DNSServiceBrowseEvent, session: BonjourDiscoverySession) {
        let peerId = event.name
        guard peerId != session.observer.peerId else { return }

        guard event.isAdded else {
            guard let instance = session.peers[peerId]?.removeInstance(interfaceIndex: event.interfaceIndex) else { return }
            instance.reset()
            scheduleReport(peerId: peerId, session: session)
            return
        }

        let peer = session.peers[peerId] ?? BonjourDiscoveredPeer()
        session.peers[peerId] = peer
        if let instance = peer.instances[event.interfaceIndex] {
            // Re-added after its resolve failed: retry it.
            guard !instance.isResolving else { return }
            startResolve(instance, peerId: peerId, session: session)
        } else {
            let instance = session.makeInstance(interfaceIndex: event.interfaceIndex, type: event.type, domain: event.domain)
            peer.add(instance)
            startResolve(instance, peerId: peerId, session: session)
        }
    }

    // MARK: - Resolve

    private func startResolve(_ instance: BonjourPeerInstance, peerId: String, session: BonjourDiscoverySession) {
        let sessionId = session.id
        let instanceId = instance.id
        let interfaceIndex = instance.interfaceIndex
        let result = client.resolve(name: peerId, type: instance.type, domain: instance.domain, interfaceIndex: interfaceIndex) { [weak self] result in
            guard let self,
                  let session = activeSession(sessionId),
                  let instance = session.peers[peerId]?.instances[interfaceIndex],
                  instance.id == instanceId else { return }
            switch result {
            case .success(let event):
                handleResolveEvent(event, instance: instance, peerId: peerId, session: session)
            case .failure(let error):
                handleInstanceError(error.code, operation: "resolve", instance: instance, peerId: peerId, session: session)
            }
        }
        switch result {
        case .success(let operation):
            instance.resolve = operation
        case .failure(let error):
            handleInstanceError(error.code, operation: "resolve", instance: instance, peerId: peerId, session: session)
        }
    }

    private func handleResolveEvent(_ event: DNSServiceResolveEvent, instance: BonjourPeerInstance, peerId: String, session: BonjourDiscoverySession) {
        let isHostChanged = instance.hostTarget != event.hostTarget
        guard isHostChanged || instance.port != event.port else { return }
        instance.port = event.port
        if isHostChanged {
            instance.addressLookup?.cancel()
            instance.addressLookup = nil
            instance.addresses = []
            instance.hostTarget = event.hostTarget
            startAddressLookup(instance, hostTarget: event.hostTarget, peerId: peerId, session: session)
        }
        scheduleReport(peerId: peerId, session: session)
    }

    private func startAddressLookup(_ instance: BonjourPeerInstance, hostTarget: String, peerId: String, session: BonjourDiscoverySession) {
        let sessionId = session.id
        let instanceId = instance.id
        let interfaceIndex = instance.interfaceIndex
        let result = client.lookupIPv4(hostname: hostTarget, interfaceIndex: interfaceIndex) { [weak self] result in
            guard let self,
                  let session = activeSession(sessionId),
                  let instance = session.peers[peerId]?.instances[interfaceIndex],
                  instance.id == instanceId,
                  instance.hostTarget == hostTarget else { return }
            switch result {
            case .success(let event):
                handleAddressEvent(event, instance: instance, peerId: peerId, session: session)
            case .failure(let error):
                handleInstanceError(error.code, operation: "lookup", instance: instance, peerId: peerId, session: session)
            }
        }
        switch result {
        case .success(let operation):
            instance.addressLookup = operation
        case .failure(let error):
            handleInstanceError(error.code, operation: "lookup", instance: instance, peerId: peerId, session: session)
        }
    }

    private func handleAddressEvent(_ event: DNSServiceAddressEvent, instance: BonjourPeerInstance, peerId: String, session: BonjourDiscoverySession) {
        guard Self.isReportable(address: event.address) else { return }
        if event.isAdded {
            guard !instance.addresses.contains(event.address) else { return }
            instance.addresses.append(event.address)
        } else {
            guard instance.addresses.contains(event.address) else { return }
            instance.addresses.removeAll { $0 == event.address }
        }
        scheduleReport(peerId: peerId, session: session)
    }

    /// A denial or a broken daemon connection concerns the whole engine. Any other error drops this
    /// instance's resolution only: it stays tracked, so the browse removing it still counts toward
    /// "lost", and the browse adding it again retries the resolve.
    private func handleInstanceError(_ code: Int32, operation: String, instance: BonjourPeerInstance, peerId: String, session: BonjourDiscoverySession) {
        switch code {
        case DNSServiceErrorCode.policyDenied, DNSServiceErrorCode.serviceNotRunning, DNSServiceErrorCode.defunctConnection:
            handleFatalError(code, operation: operation, session: session)
        default:
            Self.log.info("\(operation, privacy: .public) failed for \(peerId, privacy: .public) on interface \(instance.interfaceIndex): \(code)")
            instance.reset()
            scheduleReport(peerId: peerId, session: session)
        }
    }

    /// Link-local 169.254.x.x stays: Thunderbolt Bridge often uses it.
    private static func isReportable(address: String) -> Bool {
        address != "0.0.0.0" && !address.hasPrefix("127.")
    }

    // MARK: - Reports

    /// Coalesces a burst of changes (kDNSServiceFlagsMoreComing, several interfaces) into one report.
    private func scheduleReport(peerId: String, session: BonjourDiscoverySession) {
        guard self.session === session, session.pendingReports[peerId].isNil else { return }
        let sessionId = session.id
        session.pendingReports[peerId] = scheduler.schedule(after: Self.reportDebounce) { [weak self] in
            guard let self, let session = activeSession(sessionId) else { return }
            session.pendingReports[peerId] = nil
            report(peerId: peerId, session: session)
        }
    }

    private func report(peerId: String, session: BonjourDiscoverySession) {
        guard let peer = session.peers[peerId], !peer.instances.isEmpty else {
            session.peers[peerId] = nil
            session.lastReports[peerId] = nil
            if session.reportedPeers.remove(peerId).isNotNil {
                Self.log.info("Lost \(peerId, privacy: .public)")
                session.observer.observeLost(peerId: peerId)
            }
            return
        }
        guard let report = peer.report else {
            session.lastReports[peerId] = nil
            return
        }
        guard report != session.lastReports[peerId] else { return }
        session.lastReports[peerId] = report
        session.reportedPeers.insert(peerId)
        Self.log.info("Peer \(peerId, privacy: .public) at \(report.addresses.joined(separator: ","), privacy: .public):\(report.port)")
        session.observer.observeChange(peerId: peerId, addresses: report.addresses, port: report.port)
    }
}
