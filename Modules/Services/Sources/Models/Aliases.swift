import SwiftProtobuf

public typealias BlockId = String

extension BlockId {
    public static var empty: String = ""
}

public typealias BlockFields = [String : Google_Protobuf_Value]
