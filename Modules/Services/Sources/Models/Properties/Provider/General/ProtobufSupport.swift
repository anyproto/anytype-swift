import Foundation
import SwiftProtobuf

public protocol ProtobufSupport {
    init?(_ value: Google_Protobuf_Value)
}
