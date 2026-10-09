import Foundation
import Testing
import ProtobufMessages
@testable import Anytype

@Suite
struct BonjourDiscoveryEngineTests {

    private let client = FakeDNSServiceClient()
    private let scheduler = FakeLocalDiscoveryScheduler()
    private let observer = FakeLocalDiscoveryObserver()
    private let engine: BonjourDiscoveryEngine

    init() {
        engine = BonjourDiscoveryEngine(client: client, scheduler: scheduler)
    }

    // MARK: - Start / stop

    @Test func doesNotStartWithoutForeground() {
        engine.setObserver(observer)
        #expect(client.registrations.isEmpty)
        #expect(client.browses.isEmpty)
    }

    @Test func doesNotStartWithoutObserver() {
        engine.setForeground(true)
        #expect(client.registrations.isEmpty)
        #expect(client.browses.isEmpty)
    }

    @Test func startsWithObserverInForegroundAndRegistersUnderPeerId() throws {
        start()
        let registration = try #require(client.activeRegistrations.first)
        #expect(client.activeRegistrations.count == 1)
        #expect(registration.name == "self-peer")
        #expect(registration.type == "_anytype._tcp")
        #expect(registration.domain == "local.")
        #expect(registration.port == 62654)
        let browse = try #require(client.browse)
        #expect(browse.type == "_anytype._tcp")
        #expect(browse.domain == "local.")
    }

    @Test func backgroundStopsAndForegroundRestartsWithFreshRefs() throws {
        start()
        let firstRegistration = try #require(client.activeRegistrations.first)
        let firstBrowse = try #require(client.browse)

        engine.setForeground(false)
        #expect(firstRegistration.operation.isCancelled)
        #expect(firstBrowse.operation.isCancelled)
        #expect(client.activeRegistrations.isEmpty)

        engine.setForeground(true)
        #expect(client.registrations.count == 2)
        #expect(client.browses.count == 2)
        #expect(client.activeRegistrations.count == 1)
        #expect(client.activeBrowses.count == 1)
    }

    @Test func removeObserverStops() {
        start()
        engine.removeObserver()
        #expect(client.activeRegistrations.isEmpty)
        #expect(client.activeBrowses.isEmpty)

        engine.setForeground(false)
        engine.setForeground(true)
        #expect(client.registrations.count == 1)
    }

    @Test func newObserverReplacesTheRunningOne() throws {
        start()
        let other = FakeLocalDiscoveryObserver(peerId: "other-account", port: 62655)
        engine.setObserver(other)

        let registration = try #require(client.activeRegistrations.first)
        #expect(client.registrations.first?.operation.isCancelled == true)
        #expect(client.activeRegistrations.count == 1)
        #expect(registration.name == "other-account")
        #expect(registration.port == 62655)
        #expect(client.activeBrowses.count == 1)
    }

    @Test func stopDeallocatesRegistrationBeforeEverythingElse() {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])

        engine.setForeground(false)

        #expect(client.cancellations.first == "register")
        #expect(Set(client.cancellations) == ["register", "browse", "resolve", "lookup"])
        #expect(client.activeResolves.isEmpty)
        #expect(client.activeLookups.isEmpty)
    }

    // MARK: - Registration

    @Test func successfulRegistrationReportsHealthyState() throws {
        start()
        try #require(client.activeRegistrations.first).handler(.registered(name: "self-peer"))
        #expect(observer.errors == [0])
    }

    @Test func nameConflictRetriesRegistrationThreeTimesAfterFiveSeconds() throws {
        start()
        let browse = try #require(client.browse)

        for attempt in 1...3 {
            try #require(client.activeRegistrations.last).handler(.failed(DNSServiceError(code: DNSServiceErrorCode.nameConflict)))
            #expect(client.activeRegistrations.isEmpty)
            #expect(scheduler.pendingDelays == [5])
            scheduler.advance(by: 5)
            #expect(client.registrations.count == attempt + 1)
        }

        try #require(client.activeRegistrations.last).handler(.failed(DNSServiceError(code: DNSServiceErrorCode.nameConflict)))
        scheduler.advance(by: 60)
        #expect(client.registrations.count == 4)
        #expect(observer.errors == Array(repeating: Int(DNSServiceErrorCode.nameConflict), count: 4))
        #expect(!browse.operation.isCancelled)
    }

    @Test func withdrawnRegistrationIsRetriedLikeAConflict() throws {
        start()
        try #require(client.activeRegistrations.first).handler(.withdrawn)
        #expect(observer.errors == [Int(DNSServiceErrorCode.nameConflict)])
        scheduler.advance(by: 5)
        #expect(client.registrations.count == 2)
    }

    // MARK: - Errors

    @Test func policyDeniedReportsAndStaysStoppedUntilTheNextForeground() throws {
        start()
        try #require(client.browse).fail(DNSServiceErrorCode.policyDenied)

        #expect(observer.errors == [Int(DNSServiceErrorCode.policyDenied)])
        #expect(client.activeRegistrations.isEmpty)
        #expect(client.activeBrowses.isEmpty)
        #expect(scheduler.pendingDelays.isEmpty)
        scheduler.advance(by: 120)
        #expect(client.registrations.count == 1)

        engine.setForeground(false)
        engine.setForeground(true)
        #expect(client.registrations.count == 2)
        #expect(client.activeBrowses.count == 1)
    }

    @Test func policyDeniedAtStartReportsAndStops() {
        client.browseStartError = DNSServiceError(code: DNSServiceErrorCode.policyDenied)
        start()
        #expect(observer.errors == [Int(DNSServiceErrorCode.policyDenied)])
        #expect(client.activeRegistrations.isEmpty)
        #expect(scheduler.pendingDelays.isEmpty)
    }

    @Test func newObserverRetriesAfterPolicyDenied() throws {
        start()
        try #require(client.browse).fail(DNSServiceErrorCode.policyDenied)

        let other = FakeLocalDiscoveryObserver(peerId: "other-account")
        engine.setObserver(other)
        #expect(client.activeRegistrations.first?.name == "other-account")
    }

    @Test func daemonErrorsRestartWithExponentialBackoffCappedAtThirtySeconds() throws {
        start()
        let expectedDelays: [TimeInterval] = [1, 2, 4, 8, 16, 30, 30]
        for (index, delay) in expectedDelays.enumerated() {
            let code = index.isMultiple(of: 2) ? DNSServiceErrorCode.serviceNotRunning : DNSServiceErrorCode.defunctConnection
            try #require(client.browse).fail(code)
            #expect(client.activeRegistrations.isEmpty)
            #expect(scheduler.pendingDelays == [delay])
            scheduler.advance(by: delay)
            #expect(client.registrations.count == index + 2)
            #expect(client.activeBrowses.count == 1)
        }
        #expect(observer.errors.count == expectedDelays.count)
    }

    @Test func successfulRegistrationResetsBackoff() throws {
        start()
        try #require(client.browse).fail(DNSServiceErrorCode.serviceNotRunning)
        scheduler.advance(by: 1)
        try #require(client.browse).fail(DNSServiceErrorCode.serviceNotRunning)
        #expect(scheduler.pendingDelays == [2])
        scheduler.advance(by: 2)

        try #require(client.activeRegistrations.last).handler(.registered(name: "self-peer"))
        try #require(client.browse).fail(DNSServiceErrorCode.serviceNotRunning)
        #expect(scheduler.pendingDelays == [1])
    }

    @Test func registrationDaemonErrorRestartsTheWholeEngine() throws {
        start()
        let browse = try #require(client.browse)
        try #require(client.activeRegistrations.first).handler(.failed(DNSServiceError(code: DNSServiceErrorCode.defunctConnection)))
        #expect(browse.operation.isCancelled)
        #expect(scheduler.pendingDelays == [1])
    }

    @Test func otherErrorsRestartWithBackoff() throws {
        start()
        try #require(client.browse).fail(-65537)
        #expect(observer.errors == [-65537])
        #expect(scheduler.pendingDelays == [1])
        scheduler.advance(by: 1)
        #expect(client.activeBrowses.count == 1)
    }

    @Test func backgroundCancelsAPendingRestart() throws {
        start()
        try #require(client.browse).fail(DNSServiceErrorCode.serviceNotRunning)
        #expect(scheduler.pendingDelays == [1])

        engine.setForeground(false)
        #expect(scheduler.pendingDelays.isEmpty)

        engine.setForeground(true)
        try #require(client.browse).fail(DNSServiceErrorCode.serviceNotRunning)
        #expect(scheduler.pendingDelays == [1])
        scheduler.advance(by: 1)
        #expect(client.registrations.count == 3)
        #expect(client.activeBrowses.count == 1)
    }

    // MARK: - Reports

    @Test func burstIsDebouncedIntoOneReport() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10", "10.0.0.7"])
        #expect(observer.changes.isEmpty)

        scheduler.advance(by: 0.2)
        #expect(observer.changes.isEmpty)

        scheduler.advance(by: 0.05)
        #expect(observer.changes == [FakeObservedChange(peerId: "peer-a", addresses: ["192.168.1.10", "10.0.0.7"], port: 62654)])
    }

    @Test func unchangedStateIsNotReportedAgain() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)

        try #require(client.resolve("peer-a", interface: 4)).resolve(host: "a.local.", port: 62654)
        try #require(client.lookup("a.local.", interface: 4)).add("192.168.1.10")
        scheduler.advance(by: 1)
        #expect(observer.changes.count == 1)

        try #require(client.lookup("a.local.", interface: 4)).add("192.168.1.11")
        scheduler.advance(by: 0.25)
        #expect(observer.changes.last?.addresses == ["192.168.1.10", "192.168.1.11"])

        try #require(client.resolve("peer-a", interface: 4)).resolve(host: "a.local.", port: 62700)
        scheduler.advance(by: 0.25)
        #expect(observer.changes.last == FakeObservedChange(peerId: "peer-a", addresses: ["192.168.1.10", "192.168.1.11"], port: 62700))
        #expect(observer.changes.count == 3)
    }

    @Test func addressesAreUnionedAcrossInterfacesFirstSeenFirst() {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        discover("peer-a", interface: 9, host: "a.local.", addresses: ["169.254.7.7", "192.168.1.10"])
        scheduler.advance(by: 0.25)

        #expect(observer.changes == [FakeObservedChange(peerId: "peer-a", addresses: ["192.168.1.10", "169.254.7.7"], port: 62654)])
    }

    @Test func loopbackAndUnspecifiedAddressesAreDroppedButLinkLocalIsKept() {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["127.0.0.1", "0.0.0.0", "169.254.1.2", "10.0.0.2"])
        scheduler.advance(by: 0.25)

        #expect(observer.changes.last?.addresses == ["169.254.1.2", "10.0.0.2"])
    }

    @Test func peerWithoutAddressesIsNotReported() throws {
        start()
        try #require(client.browse).add("peer-a", interface: 4)
        try #require(client.resolve("peer-a", interface: 4)).resolve(host: "a.local.", port: 62654)
        scheduler.advance(by: 1)
        #expect(observer.changes.isEmpty)
    }

    @Test func ownInstanceIsSkipped() throws {
        start()
        try #require(client.browse).add("self-peer", interface: 4)
        #expect(client.resolves.isEmpty)
        scheduler.advance(by: 1)
        #expect(observer.changes.isEmpty)
    }

    @Test func hostTargetChangeReplacesTheAddressLookup() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)
        let oldLookup = try #require(client.lookup("a.local.", interface: 4))

        try #require(client.resolve("peer-a", interface: 4)).resolve(host: "a-2.local.", port: 62654)
        #expect(oldLookup.operation.isCancelled)
        try #require(client.lookup("a-2.local.", interface: 4)).add("192.168.1.20")
        scheduler.advance(by: 0.25)

        #expect(observer.changes.last?.addresses == ["192.168.1.20"])
    }

    // MARK: - Lost

    @Test func lostIsReportedOnlyWhenGoneFromAllInterfaces() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        discover("peer-a", interface: 9, host: "a.local.", addresses: ["169.254.7.7"])
        scheduler.advance(by: 0.25)

        try #require(client.browse).remove("peer-a", interface: 4)
        scheduler.advance(by: 0.25)
        #expect(observer.lost.isEmpty)
        #expect(observer.changes.last?.addresses == ["169.254.7.7"])

        try #require(client.browse).remove("peer-a", interface: 9)
        scheduler.advance(by: 0.25)
        #expect(observer.lost == ["peer-a"])
    }

    @Test func briefFlapWithinTheDebounceIsNotReportedLost() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)

        try #require(client.browse).remove("peer-a", interface: 4)
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)

        #expect(observer.lost.isEmpty)
        #expect(observer.changes.count == 1)
    }

    @Test func peerNeverReportedIsNotReportedLost() throws {
        start()
        try #require(client.browse).add("peer-a", interface: 4)
        try #require(client.browse).remove("peer-a", interface: 4)
        scheduler.advance(by: 1)
        #expect(observer.lost.isEmpty)
        #expect(observer.changes.isEmpty)
    }

    @Test func ownStopDoesNotReportPeersLost() {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)

        engine.setForeground(false)
        scheduler.advance(by: 1)
        engine.setForeground(true)
        engine.removeObserver()
        scheduler.advance(by: 1)

        #expect(observer.lost.isEmpty)
        #expect(observer.changes.count == 1)
    }

    @Test func peersAreReportedAgainAfterForeground() {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)

        engine.setForeground(false)
        engine.setForeground(true)
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)

        #expect(observer.changes.count == 2)
    }

    // MARK: - Per-instance errors

    @Test func resolveErrorDropsOnlyThatInstance() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        discover("peer-a", interface: 9, host: "a.local.", addresses: ["169.254.7.7"])
        scheduler.advance(by: 0.25)
        let resolve = try #require(client.resolve("peer-a", interface: 9))

        resolve.fail(-65537)
        #expect(resolve.operation.isCancelled)
        #expect(client.lookup("a.local.", interface: 9) == nil)
        #expect(client.activeBrowses.count == 1)
        scheduler.advance(by: 0.25)
        #expect(observer.changes.last?.addresses == ["192.168.1.10"])
        #expect(observer.lost.isEmpty)
        #expect(scheduler.pendingDelays.isEmpty)

        try #require(client.browse).add("peer-a", interface: 9)
        #expect(client.resolve("peer-a", interface: 9) != nil)
    }

    @Test func removeObserverDuringResolveIgnoresTheLateResult() throws {
        start()
        try #require(client.browse).add("peer-a", interface: 4)
        let resolve = try #require(client.resolve("peer-a", interface: 4))

        engine.removeObserver()
        #expect(resolve.operation.isCancelled)

        resolve.resolve(host: "a.local.", port: 62654)
        #expect(client.lookups.isEmpty)
        scheduler.advance(by: 1)
        #expect(observer.changes.isEmpty)
        #expect(observer.lost.isEmpty)
    }

    // MARK: - Review follow-ups

    @Test func policyDeniedIsRetriedWhenTheSceneReactivates() throws {
        start()
        try #require(client.browse).fail(DNSServiceErrorCode.policyDenied)

        engine.sceneDidActivate()
        #expect(client.registrations.count == 2)
        #expect(client.activeBrowses.count == 1)

        try #require(client.browse).fail(DNSServiceErrorCode.policyDenied)
        #expect(client.activeBrowses.isEmpty)
        #expect(observer.errors == [Int(DNSServiceErrorCode.policyDenied), Int(DNSServiceErrorCode.policyDenied)])
    }

    @Test func denialArrivingAfterReactivationGetsOneRetry() throws {
        start()
        engine.sceneDidActivate()
        try #require(client.browse).fail(DNSServiceErrorCode.policyDenied)
        #expect(client.registrations.count == 2)
        #expect(client.activeBrowses.count == 1)

        try #require(client.browse).fail(DNSServiceErrorCode.policyDenied)
        #expect(client.activeBrowses.isEmpty)
        #expect(scheduler.pendingDelays.isEmpty)
        #expect(observer.errors == [Int(DNSServiceErrorCode.policyDenied), Int(DNSServiceErrorCode.policyDenied)])

        engine.sceneDidActivate()
        #expect(client.registrations.count == 3)
    }

    @Test func reactivationWithoutADenialLeavesTheRunningSessionAlone() throws {
        start()
        let registration = try #require(client.activeRegistrations.first)
        engine.sceneDidActivate()
        #expect(client.registrations.count == 1)
        #expect(!registration.operation.isCancelled)
    }

    @Test func reactivationInTheBackgroundDoesNotStart() throws {
        start()
        try #require(client.browse).fail(DNSServiceErrorCode.policyDenied)
        engine.setForeground(false)
        engine.sceneDidActivate()
        #expect(client.registrations.count == 1)
    }

    @Test func resolveDaemonErrorRestartsTheWholeEngine() throws {
        start()
        try #require(client.browse).add("peer-a", interface: 4)
        try #require(client.resolve("peer-a", interface: 4)).fail(DNSServiceErrorCode.defunctConnection)

        #expect(observer.errors == [Int(DNSServiceErrorCode.defunctConnection)])
        #expect(client.activeRegistrations.isEmpty)
        #expect(client.activeBrowses.isEmpty)
        #expect(scheduler.pendingDelays == [1])
    }

    @Test func lookupPolicyDenialStopsAndReports() throws {
        start()
        try #require(client.browse).add("peer-a", interface: 4)
        try #require(client.resolve("peer-a", interface: 4)).resolve(host: "a.local.", port: 62654)
        try #require(client.lookup("a.local.", interface: 4)).handler(.failure(DNSServiceError(code: DNSServiceErrorCode.policyDenied)))

        #expect(observer.errors == [Int(DNSServiceErrorCode.policyDenied)])
        #expect(client.activeBrowses.isEmpty)
        #expect(scheduler.pendingDelays.isEmpty)
    }

    @Test func synchronousLookupDenialStopsWithoutAnOrphanReport() throws {
        client.lookupStartError = DNSServiceError(code: DNSServiceErrorCode.policyDenied)
        start()
        try #require(client.browse).add("peer-a", interface: 4)
        try #require(client.resolve("peer-a", interface: 4)).resolve(host: "a.local.", port: 62654)

        #expect(observer.errors == [Int(DNSServiceErrorCode.policyDenied)])
        #expect(client.activeRegistrations.isEmpty)
        #expect(client.activeBrowses.isEmpty)
        #expect(client.activeResolves.isEmpty)
        #expect(scheduler.pendingDelays.isEmpty)
    }

    @Test func synchronousResolveDaemonErrorRestartsTheWholeEngine() throws {
        client.resolveStartError = DNSServiceError(code: DNSServiceErrorCode.serviceNotRunning)
        start()
        try #require(client.browse).add("peer-a", interface: 4)

        #expect(observer.errors == [Int(DNSServiceErrorCode.serviceNotRunning)])
        #expect(client.activeBrowses.isEmpty)
        #expect(scheduler.pendingDelays == [1])
    }

    @Test func lookupErrorDropsOnlyThatInstance() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        try #require(client.lookup("a.local.", interface: 4)).handler(.failure(DNSServiceError(code: -65537)))

        #expect(client.resolve("peer-a", interface: 4) == nil)
        #expect(client.activeBrowses.count == 1)
        #expect(scheduler.pendingDelays == [0.25])
    }

    @Test func peerIsReportedAgainWhenItsAddressesReturn() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)

        try #require(client.lookup("a.local.", interface: 4)).remove("192.168.1.10")
        scheduler.advance(by: 0.25)
        #expect(observer.changes.count == 1)
        #expect(observer.lost.isEmpty)

        try #require(client.lookup("a.local.", interface: 4)).add("192.168.1.10")
        scheduler.advance(by: 0.25)
        #expect(observer.changes.count == 2)
        #expect(observer.changes.last == FakeObservedChange(peerId: "peer-a", addresses: ["192.168.1.10"], port: 62654))
    }

    @Test func peerIsReportedAgainAfterItsResolutionRecoversAndLostAfterItLeaves() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)

        try #require(client.resolve("peer-a", interface: 4)).fail(-65537)
        scheduler.advance(by: 0.25)
        #expect(observer.changes.count == 1)

        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)
        #expect(observer.changes.count == 2)

        try #require(client.browse).remove("peer-a", interface: 4)
        scheduler.advance(by: 0.25)
        #expect(observer.lost == ["peer-a"])
    }

    @Test func lostThenRediscoveredPeerIsReportedAgain() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)
        try #require(client.browse).remove("peer-a", interface: 4)
        scheduler.advance(by: 0.25)

        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)

        #expect(observer.lost == ["peer-a"])
        #expect(observer.changes.count == 2)
    }

    @Test func reportPairsAddressesOnlyWithTheirOwnPort() throws {
        start()
        try #require(client.browse).add("peer-a", interface: 4)
        try #require(client.resolve("peer-a", interface: 4)).resolve(host: "a.local.", port: 62654)
        discover("peer-a", interface: 9, host: "a.local.", port: 62655, addresses: ["169.254.7.7"])
        scheduler.advance(by: 0.25)
        #expect(observer.changes.last == FakeObservedChange(peerId: "peer-a", addresses: ["169.254.7.7"], port: 62655))

        try #require(client.lookup("a.local.", interface: 4)).add("192.168.1.10")
        scheduler.advance(by: 0.25)
        #expect(observer.changes.last == FakeObservedChange(peerId: "peer-a", addresses: ["192.168.1.10"], port: 62654))
    }

    @Test func reAddedInterfaceMovesToTheEndOfTheOrder() throws {
        start()
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        discover("peer-a", interface: 9, host: "a.local.", addresses: ["169.254.7.7"])
        scheduler.advance(by: 0.25)

        try #require(client.browse).remove("peer-a", interface: 4)
        discover("peer-a", interface: 4, host: "a.local.", addresses: ["192.168.1.10"])
        scheduler.advance(by: 0.25)

        #expect(observer.changes.last?.addresses == ["169.254.7.7", "192.168.1.10"])
    }

    @Test func duplicateBrowseAddDoesNotRestartTheResolve() throws {
        start()
        try #require(client.browse).add("peer-a", interface: 4)
        try #require(client.browse).add("peer-a", interface: 4)
        #expect(client.resolves.count == 1)
    }

    @Test func synchronousRegisterFailureDoesNotStartAnOrphanBrowse() {
        client.registerStartError = DNSServiceError(code: DNSServiceErrorCode.defunctConnection)
        start()
        #expect(client.browses.isEmpty)
        #expect(observer.errors == [Int(DNSServiceErrorCode.defunctConnection)])
        #expect(scheduler.pendingDelays == [1])

        client.registerStartError = nil
        scheduler.advance(by: 1)
        #expect(client.activeRegistrations.count == 1)
        #expect(client.activeBrowses.count == 1)
    }

    @Test func lateCallbackFromAReplacedSessionIsIgnored() throws {
        start()
        try #require(client.browse).add("peer-a", interface: 4)
        let staleResolve = try #require(client.resolve("peer-a", interface: 4))

        let other = FakeLocalDiscoveryObserver(peerId: "other-account")
        engine.setObserver(other)
        try #require(client.browse).add("peer-a", interface: 4)
        staleResolve.resolve(host: "stale.local.", port: 1)
        scheduler.advance(by: 1)

        #expect(client.lookups.isEmpty)
        #expect(observer.changes.isEmpty)
        #expect(other.changes.isEmpty)
    }

    @Test func stopCancelsAPendingConflictRetry() throws {
        start()
        try #require(client.activeRegistrations.first).handler(.failed(DNSServiceError(code: DNSServiceErrorCode.nameConflict)))
        engine.setForeground(false)
        scheduler.advance(by: 10)
        #expect(client.registrations.count == 1)
    }

    // MARK: - Helpers

    private func start() {
        engine.setObserver(observer)
        engine.setForeground(true)
    }

    private func discover(_ peerId: String, interface: UInt32, host: String, port: Int = 62654, addresses: [String]) {
        client.browse?.add(peerId, interface: interface)
        client.resolve(peerId, interface: interface)?.resolve(host: host, port: port)
        for address in addresses {
            client.lookup(host, interface: interface)?.add(address)
        }
    }
}
