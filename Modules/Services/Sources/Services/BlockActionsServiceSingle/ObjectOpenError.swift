import Foundation
import ProtobufMessages

public enum ObjectOpenError: Error {
    case anytypeNeedsUpgrade
    case unknownError
}

extension ObjectOpenError {
    init(error: Anytype_Rpc.Object.Open.Response.Error) {
        switch error.code {
        case .anytypeNeedsUpgrade:
            self = .anytypeNeedsUpgrade
        case .badInput, .notFound, .unknownError, .null, .UNRECOGNIZED:
            self = .unknownError
        }
    }
}
