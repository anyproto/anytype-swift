import Foundation

public enum KeychainError: Error {
    case stringItem2DataConversionError
    case data2StringItemConversionError
    case keychainError(status: OSStatus)
    case unknownError(message: String)
}
