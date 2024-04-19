import Foundation

public protocol ResultWithError {
    
    associatedtype Error: ResponseError
    
    var error: Error { get }
    
    var event: Anytype_ResponseEvent { get }
    var hasEvent: Bool { get }
}

extension ResultWithError {
    public var event: Anytype_ResponseEvent { Anytype_ResponseEvent() }
    public var hasEvent: Bool { false }
}

public protocol ResponseError: Swift.Error {
    
    associatedtype ErrorCode: RawRepresentable where ErrorCode.RawValue == Int
    
    var isNull: Bool { get }
    
    var code: ErrorCode { get }
    var description_p: String { get }
}
