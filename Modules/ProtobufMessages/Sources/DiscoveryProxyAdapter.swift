import Foundation
import Lib
import os

/// Middleware side of LAN discovery: what to advertise, and where to report peers.
/// Every `observe*` call returns immediately (middleware runs the work on its own goroutines),
/// so it may be called from any thread.
public protocol LocalDiscoveryObserver: AnyObject, Sendable {
    var port: Int { get }
    var peerId: String { get }
    var serviceType: String { get }
    func observeChange(peerId: String, addresses: [String], port: Int)
    func observeLost(peerId: String)
    /// Code 0 reports a healthy (re)registration and clears an earlier error state in middleware.
    func observeError(code: Int, message: String)
}

/// Platform LAN discovery that middleware drives: `setObserver` when an account starts
/// local discovery, `removeObserver` when it stops. Called from arbitrary threads.
public protocol LocalDiscoveryProxy: AnyObject, Sendable {
    func setObserver(_ observer: any LocalDiscoveryObserver)
    func removeObserver()
}

public final class DiscoveryProxyAdapter: Sendable {

    public static let shared = DiscoveryProxyAdapter()

    // Go keeps only a gomobile reference to the bridge; the Swift object must stay alive here.
    private let bridge = OSAllocatedUnfairLock<DiscoveryProxyBridge?>(initialState: nil)

    private init() {}

    /// Must be called once per process, before any account starts: middleware picks native
    /// discovery or its zeroconf fallback at account start, depending on whether a proxy is installed.
    public func install(_ proxy: any LocalDiscoveryProxy) {
        let bridge = DiscoveryProxyBridge(proxy: proxy)
        self.bridge.withLock { $0 = bridge }
        Lib.ServiceSetDiscoveryProxy(bridge)
    }
}

/// Private `ServiceDiscoveryProxyProtocol` adoption.
fileprivate final class DiscoveryProxyBridge: NSObject, Sendable, ServiceDiscoveryProxyProtocol {

    private let proxy: any LocalDiscoveryProxy

    init(proxy: any LocalDiscoveryProxy) {
        self.proxy = proxy
    }

    func setObserver(_ observer: (any ServiceDiscoveryObserverProtocol)?) {
        guard let observer else {
            proxy.removeObserver()
            return
        }
        proxy.setObserver(DiscoveryObserver(observer: observer))
    }

    func removeObserver() {
        proxy.removeObserver()
    }
}

// The gomobile observer is a Go object: safe to call from any thread.
fileprivate final class DiscoveryObserver: LocalDiscoveryObserver, @unchecked Sendable {

    let port: Int
    let peerId: String
    let serviceType: String

    private let observer: any ServiceDiscoveryObserverProtocol

    init(observer: any ServiceDiscoveryObserverProtocol) {
        self.observer = observer
        self.port = observer.port()
        self.peerId = observer.peerId()
        self.serviceType = observer.serviceType()
    }

    func observeChange(peerId: String, addresses: [String], port: Int) {
        observer.observeChange(
            DiscoveryObservationResult(peerId: peerId, ip: addresses.joined(separator: ","), port: port)
        )
    }

    func observeLost(peerId: String) {
        observer.observeLost(peerId)
    }

    func observeError(code: Int, message: String) {
        observer.observeError(code, message: message)
    }
}

/// Private `ServiceObservationResultProtocol` adoption: one discovered peer.
fileprivate final class DiscoveryObservationResult: NSObject, Sendable, ServiceObservationResultProtocol {

    private let peerIdValue: String
    private let ipValue: String
    private let portValue: Int

    init(peerId: String, ip: String, port: Int) {
        self.peerIdValue = peerId
        self.ipValue = ip
        self.portValue = port
    }

    func ip() -> String {
        ipValue
    }

    func peerId() -> String {
        peerIdValue
    }

    func port() -> Int {
        portValue
    }
}
