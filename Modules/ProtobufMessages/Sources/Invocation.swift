import Foundation
import Combine
import SwiftProtobuf

public struct Invocation<Request, Response> where Request: Message,
                                            Response: ResultWithError,
                                            Response: Message {
    
    private let messageName: String
    private let request: Request
    private let invokeTask: (Request) throws -> Response
    
    init(messageName: String, request: Request, invokeTask: @escaping (Request) throws -> Response) {
        self.messageName = messageName
        self.request = request
        self.invokeTask = invokeTask
    }
    
    public func invoke(file: StaticString) async throws -> Response {
        let value = try await Task {
           try syncInvoke(file: file)
        }.value
        try Task.checkCancellation()
        return value
    }
    
    public func invoke(file: StaticString) throws -> Response {
        return try syncInvoke(file: file)
    }
    
    private func syncInvoke(file: StaticString) throws -> Response {
        
        // Helper for https://linear.app/anytype/issue/IOS-1169
        // Turn on after migration of methods that call longer 5 ms.
//        let start = DispatchTime.now()
//
//        defer {
//            if Thread.isMainThread {
//                let end = DispatchTime.now()
//                let timeMs = (end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
//                if timeMs > 5 {
//                    InvocationSettings.handler?.assertationHandler(message: "Method \(messageName) called on main thread", info: ["Time ms": "\(timeMs)"], file: file)
//                }
//            }
//        }
        
        let result: Response
        
        do {
            result = try invokeTask(request)
        } catch {
            log(message: messageName, rquest: request, response: nil, error: error)
            throw error
        }
        
        log(message: messageName, rquest: request, response: result, error: result.error.isNull ? nil : result.error)
        
        if !result.error.isNull {
            throw result.error
        }
        
        if result.hasEvent {
            InvocationSettings.handler?.eventHandler(event: result.event)
        }
        
        return result
    }
    
    private func log(message: String, rquest: Request, response: Response?, error: Error?) {
        
        let name: String
        if let response, !response.event.messages.isEmpty {
            let messageNames = (try? response.event.jsonUTF8Data())?.parseMessages() ?? ""
            name = "\(message),Events:\(messageNames)"
        } else {
            name = message
        }
        
        let message = InvocationMessage(
            name: name,
            requestJsonData: try? request.jsonUTF8Data(),
            responseJsonData: try? response?.jsonUTF8Data(),
            responseError: error
        )
        InvocationSettings.handler?.logHandler(message: message)
    }
}
