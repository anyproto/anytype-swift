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
        return try await Task {
            try self.syncInvoke(file: file)
        }.value
    }
    
    public func invoke(file: StaticString) throws -> Response {
        return try syncInvoke(file: file)
    }
    
    private func syncInvoke(file: StaticString) throws -> Response {
        
        let start = DispatchTime.now()

        defer {
            if Thread.isMainThread {
                let end = DispatchTime.now()
                let timeMs = (end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
                if timeMs > 5 {
                    InvocationSettings.handler?.assertationHandler(message: "Method \(messageName) called on main thread", info: ["Time ms": "\(timeMs)"], file: file)
                }
            }
        }
        
        let result: Response
        
        do {
            result = try invokeTask(request)
        } catch {
            log(message: messageName, rquest: request, respose: nil, error: error)
            throw error
        }
        
        log(message: messageName, rquest: request, respose: result, error: result.error.isNull ? nil : result.error)
        
        if !result.error.isNull {
            throw result.error
        }
        
        if result.hasEvent {
            InvocationSettings.handler?.handle(event: result.event)
        }
        
        return result
    }
    
    private func log(message: String, rquest: Request, respose: Response?, error: Error?) {
        let message = InvocationMessage(
            name: message,
            requestJsonData: try? request.jsonUTF8Data(),
            responseJsonData: try? respose?.jsonUTF8Data(),
            responseError: error
        )
        InvocationSettings.handler?.handle(message: message)
    }
}
