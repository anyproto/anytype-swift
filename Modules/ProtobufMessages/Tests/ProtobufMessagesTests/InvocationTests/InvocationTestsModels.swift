import Testing
import SwiftProtobuf
@testable import ProtobufMessages

struct TestRequest: Message {
    init() {}
    
    static let protoMessageName: String = ""
    
    var unknownFields: SwiftProtobuf.UnknownStorage = SwiftProtobuf.UnknownStorage()
    
    mutating func decodeMessage<D>(decoder: inout D) throws where D : SwiftProtobuf.Decoder {}
    
    func traverse<V>(visitor: inout V) throws where V : SwiftProtobuf.Visitor {}
    
    func isEqualTo(message: any SwiftProtobuf.Message) -> Bool {
        return false
    }
}

struct TestResponse: ResultWithError, Message {
    
    var error: TestResponseError { TestResponseError() }
    
    var event: Anytype_ResponseEvent { Anytype_ResponseEvent() }
    var hasEvent: Bool { false }
    
    init() {}
    
    static let protoMessageName: String = ""
    
    var unknownFields: SwiftProtobuf.UnknownStorage = SwiftProtobuf.UnknownStorage()
    
    mutating func decodeMessage<D>(decoder: inout D) throws where D : SwiftProtobuf.Decoder {}
    
    func traverse<V>(visitor: inout V) throws where V : SwiftProtobuf.Visitor {}
    
    func isEqualTo(message: any SwiftProtobuf.Message) -> Bool {
        return false
    }
}

struct TestResponseError: ResponseError {
    var isNull: Bool { true }
    
    var code: TestResponseErrorCode { .test }
    var description_p: String { "" }
}

enum TestResponseErrorCode: Int {
    case test
}
