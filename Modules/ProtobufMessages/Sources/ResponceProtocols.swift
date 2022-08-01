import Foundation

public protocol ResultWithError {
    
    associatedtype Error: ResponseError
    
    var error: Error { get }
}

public protocol ResponseError {
    
    associatedtype ErrorCode: RawRepresentable
    
    var isNull: Bool { get }
    
    var code: ErrorCode { get }
    var description_p: String { get }
}
