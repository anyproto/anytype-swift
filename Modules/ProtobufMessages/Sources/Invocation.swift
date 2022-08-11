import Foundation
import Combine
import SwiftProtobuf

enum Anytype_Middleware_Error: Error {
    case unknownError
    static let domain: String = "org.anytype.middleware.services"
}

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
    private let invokeTask: (Request) -> Response?
    
    init(messageName: String, request: Request, invokeTask: @escaping (Request) -> Response?) {
        self.messageName = messageName
        self.request = request
        self.invokeTask = invokeTask
    }
    
    public func invoke() async throws -> Response {
        typealias Continuation = CheckedContinuation<Response, Error>
        return try await withCheckedThrowingContinuation { (continuation: Continuation) in
            DispatchQueue.invocationQueue.async {
                let result = self.result()
                switch result {
                case let .success(data):
                    continuation.resume(returning: data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func invoke() -> Result<Response, Error> {
        return result()
    }
    
    public func invoke(on queue: DispatchQueue? = nil) -> Future<Response, Error> {
        return Future<Response, Error> { promise in
            if let queue = queue {
                queue.async {
                    promise(self.result())
                }
            } else {
                promise(self.result())
            }
        }
    }
    
    private func result() -> Result<Response, Error> {
        guard let result = invokeTask(request) else {
            log(message: messageName, rquest: request, respose: nil, error: Anytype_Middleware_Error.unknownError)
            return .failure(Anytype_Middleware_Error.unknownError)
        }
        
        log(message: messageName, rquest: request, respose: result, error: result.error.toSystemError())
        
        if let error = result.error.toSystemError() {
            return .failure(error)
        } else {
            return .success(result)
        }
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
