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
    
    @discardableResult
    public func invoke(
        file: StaticString = #file,
        function: String = #function,
        line: UInt = #line,
        shouldHandleEvent: Bool = false
    ) async throws -> Response {
        do {
            return try await internalInvoke(shouldHandleEvent: shouldHandleEvent)
        } catch let error as CancellationError {
            // Ignore try Task.checkCancellation()
            throw error
        } catch {
            InvocationSettings.handler?.assertationHandler(message: error.localizedDescription, info: [:], file: file, function: function, line: line)
            throw error
        }
    }
    
    // MARK: - Private
    
    private func internalInvoke(shouldHandleEvent: Bool) async throws -> Response {
        
        let result: Response
        
        do {
            result = try await Task {
                try invokeTask(request)
            }.value
        } catch {
            log(message: messageName, rquest: request, response: nil, error: error)
            throw error
        }
        
        log(message: messageName, rquest: request, response: result, error: result.error.isNull ? nil : result.error)
        
        if !result.error.isNull {
            throw result.error
        }
        
        if shouldHandleEvent && result.hasEvent {
            await InvocationSettings.handler?.eventHandler(event: result.event)
        }
        
        try Task.checkCancellation()
        
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
