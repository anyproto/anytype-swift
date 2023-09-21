import Foundation
import SecureService

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .stringItem2DataConversionError:
            return Loc.Keychain.Error.stringToDataConversionError
        case .data2StringItemConversionError:
            return Loc.Keychain.Error.dataToStringConversionError
        case .unknownError(let message):
            return NSLocalizedString(message, comment: "")
        case .keychainError(let status):
            let statusMessage = SecCopyErrorMessageString(status, nil) as String? ?? Loc.Keychain.Error.unknownKeychainError
            return NSLocalizedString(statusMessage, comment: "")
        }
    }
}
