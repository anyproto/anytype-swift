import Foundation
import Lib
import SwiftProtobuf

/// Adapts interface of private framework.
public protocol ServiceEventsHandlerProtocol: AnyObject {
    func handle(_ event: Anytype_Event)
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
public class ServiceMessageHandlerAdapter: NSObject {
    
    public typealias Adapter = ServiceEventsHandlerProtocol
    private(set) weak var value: Adapter?
    
    public init(value: Adapter) {
        self.value = value
        super.init()
        self.listen()
    }
    
    public override init() {
        super.init()
    }
    
    public func with(value: Adapter?) -> Self {
        self.value = value
        if value != nil {
            self.listen()
        }
        return self
    }
  
    /// Don't forget to call it.
    public func listen() {
        Lib.ServiceSetEventHandlerMobile(self)
    }
}

/// Private `ServiceMessageHandlerProtocol` adoption.
extension ServiceMessageHandlerAdapter: ServiceMessageHandlerProtocol {
    public func handle(_ data: Data?) {
        guard let data = data,
              let event = try? Anytype_Event(serializedData: data)
        else { return }

        log(event: event)
        self.value?.handle(event)
    }
    
    private func log(event: Anytype_Event) {
        let message = InvocationMessage(
            name: "Event",
            requestJsonData: nil,
            responseJsonData: try? event.jsonUTF8Data(),
            responseError: nil
        )
        InvocationSettings.handler?.handle(message: message)
    }
}
