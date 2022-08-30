import Foundation

public protocol ResultWithError {
    
    associatedtype Error: ResponseError
    
    var error: Error { get }
}

public protocol ResponseError {
    
    associatedtype ErrorCode: RawRepresentable where ErrorCode.RawValue == Int
    
    var isNull: Bool { get }
    
    var code: ErrorCode { get }
    var description_p: String { get }
}


extension ResponseError {
    func toSystemError() -> Error? {
        guard !isNull else { return nil }
        let domain = Anytype_Middleware_Error.domain
        let code = code.rawValue
        let description = description_p
        return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
