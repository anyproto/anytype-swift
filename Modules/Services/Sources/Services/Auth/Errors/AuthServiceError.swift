import Foundation
import ProtobufMessages

public typealias RecoverAccountErrorCode = Anytype_Rpc.Account.Recover.Response.Error.Code

public enum AuthServiceError: Error {
    case createWalletError
    case recoverWalletError
    case recoverAccountError(code: RecoverAccountErrorCode)
    case selectAccountError
}
