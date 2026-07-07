import Foundation
import Lib
import SwiftProtobuf
import os

/// Adapts interface of private framework.
public protocol ServiceEventsHandlerProtocol: AnyObject {
    func handle(_ event: Anytype_Event) async
}

/// Provides the following functionality
/// - Receive events from `Lib` and transfer them to a wrapped value.
///
/// In a nutshell, it do the following.
///
/// - It consumes ( with a weak ownership ) a value which adopts public interface.
/// - Subscribes as event handler to library events stream.
/// - Transfer events from library to a value.
///
public class ServiceMessageHandlerAdapter: @unchecked Sendable {
    
    private let lock = OSAllocatedUnfairLock()

    private var handlers: [WeakHandler] = []
    private var listener: ServiceMessageHandler?
    
    public static let shared = ServiceMessageHandlerAdapter()
    
    private init() {
        listen()
    }
    
    public func addHandler(handler: ServiceEventsHandlerProtocol) {
        lock.lock()
        defer { lock.unlock() }
        handlers.removeAll { $0.value == nil }
        handlers.append(WeakHandler(handler))
    }

    private func currentHandlers() -> [WeakHandler] {
        lock.lock()
        defer { lock.unlock() }
        return handlers
    }

    private func listen() {
        lock.lock()
        defer { lock.unlock() }
        listener = ServiceMessageHandler { [weak self] event in
            guard let self else { return }
            // Snapshot under the lock and release it before awaiting: reading
            // `handlers` unsynchronized races with `addHandler`, and the lock
            // must not be held across the suspension point.
            for handler in currentHandlers() {
                await handler.value?.handle(event)
            }
        }
        Lib.ServiceSetEventHandlerMobile(listener)
    }
}

/// Private `ServiceMessageHandlerProtocol` adoption.
fileprivate final class ServiceMessageHandler: NSObject, Sendable, ServiceMessageHandlerProtocol {

    // A Task per incoming chunk gives no FIFO guarantee — reordered events
    // (e.g. subscriptionAdd after the amend that follows it) corrupt storages.
    // Chunks are buffered in arrival order and drained by a single consumer.
    private let continuation: AsyncStream<Data>.Continuation
    private let consumer: Task<Void, Never>

    init(handler: @escaping @Sendable (_: Anytype_Event) async -> Void) {
        let (stream, continuation) = AsyncStream.makeStream(of: Data.self)
        self.continuation = continuation
        self.consumer = Task {
            for await data in stream {
                guard let event = try? Anytype_Event(serializedBytes: data) else { continue }
                Self.log(event: event)
                await handler(event)
            }
        }
    }

    deinit {
        continuation.finish()
        consumer.cancel()
    }

    public func handle(_ data: Data?) {
        guard let data else { return }
        continuation.yield(data)
    }

    private static func log(event: Anytype_Event) {
        guard let handler = InvocationSettings.handler, handler.isLogEnabled else { return }

        let responseJsonData = try? event.jsonUTF8Data()
        let messageNames = responseJsonData?.parseMessages() ?? ""

        let message = InvocationMessage(
            name: "Events:\(messageNames)",
            requestJsonData: nil,
            responseJsonData: responseJsonData,
            responseError: nil
        )
        handler.logHandler(message: message)
    }
}
