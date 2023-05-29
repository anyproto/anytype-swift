import Foundation
import Combine
import SwiftProtobuf

private extension DispatchQueue {
    static let invocationQueue = DispatchQueue(
        label: "com.middlewate-invocation",
        qos: .userInitiated
    )
}

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
    
    public func invoke() async throws -> Response {
        typealias Continuation = CheckedContinuation<Response, Error>
        return try await withCheckedThrowingContinuation { (continuation: Continuation) in
            DispatchQueue.invocationQueue.async {
                do {
                    let data = try self.syncInvoke()
                    continuation.resume(returning: data)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func invoke() throws -> Response {
        return try syncInvoke()
    }
    
    private func syncInvoke() throws -> Response {
        
        let start = DispatchTime.now()

        defer {
            if Thread.isMainThread {
                let end = DispatchTime.now()
                let timeMs = (end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
                if timeMs > 5 {
                    InvocationSettings.handler?.assertationHandler(message: "Method \(messageName) called on main thread", info: ["Time ms": "\(timeMs)"])
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
