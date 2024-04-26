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
    public func invoke(file: StaticString = #file, function: String = #function, line: UInt = #line) async throws -> Response {
        do {
            return try await internalInvoke()
        } catch let error as CancellationError {
            // Ignore try Task.checkCancellation()
            throw error
        } catch {
            InvocationSettings.handler?.assertationHandler(message: error.localizedDescription, info: [:], file: file, function: function, line: line)
            throw error
        }
    }
    
    // MARK: - Private
    
    private func internalInvoke() async throws -> Response {
        
        let result: Response
        
        let requestId = await RequestIdStorage.shared.createId()
        
        log(message: messageName, requestId: requestId, data: request)
        
        do {
            result = try await Task {
                try invokeTask(request)
            }.value
        } catch {
            log(message: messageName, requestId: requestId, data: nil, error: error)
            throw error
        }
        
        log(message: messageName, requestId: requestId, data: result, error: result.error.isNull ? nil : result.error)
        
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
