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
    
    private func listen() {
        lock.lock()
        defer { lock.unlock() }
        listener = ServiceMessageHandler { [weak self] event in
            guard let self else { return }
            for handler in handlers {
                await handler.value?.handle(event)
            }
        }
        Lib.ServiceSetEventHandlerMobile(listener)
    }
}

/// Private `ServiceMessageHandlerProtocol` adoption.
fileprivate final class ServiceMessageHandler: NSObject, Sendable, ServiceMessageHandlerProtocol {
    
    let handler: @Sendable (_ event: Anytype_Event) async -> Void
    
    init(handler: @escaping @Sendable (_: Anytype_Event) async -> Void) {
        self.handler = handler
    }
    
    public func handle(_ data: Data?) {
        Task {
            guard let data = data,
                  let event = try? Anytype_Event(serializedBytes: data)
            else { return }
            
            log(event: event)
            await handler(event)
        }
    }
    
    private func log(event: Anytype_Event) {
        
        let responseJsonData = try? event.jsonUTF8Data()
        let messageNames = responseJsonData?.parseMessages() ?? ""
        
        let message = InvocationMessage(
            name: "Events:\(messageNames)",
            requestJsonData: nil,
            responseJsonData: responseJsonData,
            responseError: nil
        )
        InvocationSettings.handler?.logHandler(message: message)
    }
}
