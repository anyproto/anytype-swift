//
//  KeychainError.swift
//  AnyType
//
//  Created by Denis Batvinkin on 18.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

public enum KeychainError: Error {
    case stringItem2DataConversionError
    case data2StringItemConversionError
    case keychainError(status: OSStatus)
    case unknownError(message: String)
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .stringItem2DataConversionError:
            return NSLocalizedString("String to Data conversion error", comment: "")
        case .data2StringItemConversionError:
            return NSLocalizedString("Data to String conversion error", comment: "")
        case .unknownError(let message):
            return NSLocalizedString(message, comment: "")
        case .keychainError(let status):
            let statusMessage = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unknown Keychain Error", comment: "")
            return NSLocalizedString(statusMessage, comment: "")
        }
    }
}
