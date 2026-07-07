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
        qos: DispatchQoS.QoSClass = .default,
        file: StaticString = #file,
        function: String = #function,
        line: UInt = #line,
        ignoreLogErrors: Response.Error.ErrorCode...
    ) async throws -> Response {
        do {
            return try await withUncancellableHandler {
                try await internalInvoke(requestMask: requestMask, responseMask: responseMask, qos: qos)
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
        responseMask: ((inout Response) -> Void)?,
        qos: DispatchQoS.QoSClass
    ) async throws -> Response {
        
        let result: Response
        
        let logEnabled = InvocationSettings.handler?.isLogEnabled ?? false
        let requestId = logEnabled ? await RequestIdStorage.shared.createId() : 0

        if logEnabled {
            var requestForLog = request
            requestMask?(&requestForLog)
            log(message: messageName, requestId: requestId, data: requestForLog)
        }
        
        try Task.checkCancellation()
        
        do {
            result = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Response, Error>) in
                DispatchQueue.global(qos: qos).async {
                    do {
                        let response = try invokeTask(request)
                        cont.resume(returning: response)
                    } catch {
                        cont.resume(throwing: error)
                    }
                }
            }
        } catch {
            log(message: messageName, requestId: requestId, data: nil, error: error)
            throw error
        }
        
        if logEnabled {
            var resultForLog = result
            responseMask?(&resultForLog)
            let errorForLog = result.error.isNull ? nil : result.error
            log(message: messageName, requestId: requestId, data: resultForLog, error: errorForLog)
        }
        
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
        guard let handler = InvocationSettings.handler, handler.isLogEnabled else { return }
        let message = InvocationMessage(
            name: "\(message)-Request-\(requestId)",
            requestJsonData: nil,
            responseJsonData: try? data?.jsonUTF8Data(),
            responseError: nil
        )
        handler.logHandler(message: message)
    }

    private func log(message: String, requestId: Int, data: Response?, error: Error?) {
        guard let handler = InvocationSettings.handler, handler.isLogEnabled else { return }

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
        handler.logHandler(message: message)
    }
}
