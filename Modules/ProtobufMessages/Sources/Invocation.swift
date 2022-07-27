import Foundation
import Combine

enum Anytype_Middleware_Error: Error {
    case unknownError
    static let domain: String = "org.anytype.middleware.services"
}

private extension DispatchQueue {
    /// Middleware provide a save access to one object and parallel access to different
    static let invocationQueue = DispatchQueue(
        label: "com.middlewate-invocation",
        qos: .userInitiated
    )
}

public struct Invocation<Response> where Response: ResultWithError, Response.Error.ErrorCode.RawValue == Int {
    
    private let invokeTask: () -> Response?
    
    init(invokeTask: @escaping () -> Response?) {
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
        guard let result = invokeTask() else {
            return .failure(Anytype_Middleware_Error.unknownError)
        }
        
        if !result.error.isNull {
            let domain = Anytype_Middleware_Error.domain
            let code = result.error.code.rawValue
            let description = result.error.description_p
            return .failure(NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
        } else {
            return .success(result)
        }
    }
}
