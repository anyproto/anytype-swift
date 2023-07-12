import Foundation

public struct InvocationMessage {
    public let name: String
    public let requestJsonData: Data?
    public let responseJsonData: Data?
    public let responseError: Error?
}

public protocol InvocationMesagesHandlerProtocol: AnyObject {
    func logHandler(message: InvocationMessage)
    func eventHandler(event: Anytype_ResponseEvent) async
    func assertationHandler(message: String, info: [String: String], file: StaticString, function: String, line: UInt)
}
