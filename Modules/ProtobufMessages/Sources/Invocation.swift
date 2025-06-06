import Foundation
import Combine
import SwiftProtobuf

public struct Invocation<Request, Response>: Sendable where Request: Message & Sendable,
                                                  Response: ResultWithError & Message & Sendable {
    
    private let messageName: String
    private let request: Request
    private let invokeTask: @Sendable (Request) throws -> Response
    
    init(messageName: String, request: Request, invokeTask: @escaping @Sendable (Request) throws -> Response) {
        self.messageName = messageName
        self.request = request
        self.invokeTask = invokeTask
    }
    
    @discardableResult
    public func invoke(
        requestMask: (@Sendable (inout Request) -> Void)? = nil,
        responseMask: (@Sendable (inout Response) -> Void)? = nil,
        file: StaticString = #file,
        function: String = #function,
        line: UInt = #line,
        ignoreLogErrors: Response.Error.ErrorCode...
    ) async throws -> Response {
        do {
            return try await withUncancellableHandler {
                try await internalInvoke(requestMask: requestMask, responseMask: responseMask)
            }
        } catch let error as CancellationError {
            // Ignore try Task.checkCancellation()
            throw error
        } catch let error as Response.Error where ignoreLogErrors.map(\.rawValue).contains(error.code.rawValue) {
            // Ignore some specific errors
            throw error
        } catch {
            InvocationSettings.handler?.assertationHandler(message: error.localizedDescription, domain: "Middle.\(messageName)", info: [:], file: file, function: function, line: line)
            throw error
        }
    }
    
    // MARK: - Private
    
    private func internalInvoke(
        requestMask: ((inout Request) -> Void)?,
        responseMask: ((inout Response) -> Void)?
    ) async throws -> Response {
        
        let result: Response
        
        let requestId = await RequestIdStorage.shared.createId()
    
        var requestForLog = request
        requestMask?(&requestForLog)
        log(message: messageName, requestId: requestId, data: requestForLog)
        
        try Task.checkCancellation()
        
        do {
            result = try await Task {
                try invokeTask(request)
            }.value
        } catch {
            log(message: messageName, requestId: requestId, data: nil, error: error)
            throw error
        }
        
        var resultForLog = result
        responseMask?(&resultForLog)
        let errorForLog = result.error.isNull ? nil : result.error
        log(message: messageName, requestId: requestId, data: resultForLog, error: errorForLog)
        
        if !result.error.isNull {
            throw result.error
        }
        
        if result.hasEvent {
            await InvocationSettings.handler?.eventHandler(event: result.event)
        }
        
        try Task.checkCancellation()
        
        return result
    }
    
    private func log(message: String, requestId: Int, data: Request?) {
        let message = InvocationMessage(
            name: "\(message)-Request-\(requestId)",
            requestJsonData: nil,
            responseJsonData: try? data?.jsonUTF8Data(),
            responseError: nil
        )
        InvocationSettings.handler?.logHandler(message: message)
    }
    
    private func log(message: String, requestId: Int, data: Response?, error: Error?) {
        
        let name: String
        if let data, !data.event.messages.isEmpty {
            let messageNames = (try? data.event.jsonUTF8Data())?.parseMessages() ?? ""
            name = "\(message)-Events:\(messageNames)"
        } else {
            name = message
        }
        
        let message = InvocationMessage(
            name: "\(name)-Response-\(requestId)",
            requestJsonData: nil,
            responseJsonData: try? data?.jsonUTF8Data(),
            responseError: error
        )
        InvocationSettings.handler?.logHandler(message: message)
    }
}
