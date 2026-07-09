import Foundation

public struct InvocationMessage {
    public let name: String
    public let requestJsonData: Data?
    public let responseJsonData: Data?
    public let responseError: Error?
}

public protocol InvocationMesagesHandlerProtocol: AnyObject {
    // Checked before building InvocationMessage — protobuf→JSON encoding is
    // too expensive to pay when logging is disabled.
    var isLogEnabled: Bool { get }
    func logHandler(message: InvocationMessage)
    func eventHandler(event: Anytype_ResponseEvent) async
    func assertationHandler(message: String, domain: String, info: [String: String], file: StaticString, function: String, line: UInt)
}
