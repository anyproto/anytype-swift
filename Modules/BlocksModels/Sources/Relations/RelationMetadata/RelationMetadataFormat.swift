import Foundation
import SwiftUI

public extension RelationMetadata {
    
    enum Format: Hashable {
        case longText
        case shortText
        case number
        case status
        case date
        case file
        case checkbox
        case url
        case email
        case phone
        case tag
        case object
        case unrecognized(Int)
    }
}

extension RelationMetadata.Format {
    
    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .longText
        case 1: self = .shortText
        case 2: self = .number
        case 3: self = .status
        case 4: self = .date
        case 5: self = .file
        case 6: self = .checkbox
        case 7: self = .url
        case 8: self = .email
        case 9: self = .phone
        case 11: self = .tag
        case 100: self = .object
        default: self = .unrecognized(rawValue)
        }
    }
    
    var rawValue: Int {
        switch self {
        case .longText: return 0
        case .shortText: return 1
        case .number: return 2
        case .status: return 3
        case .date: return 4
        case .file: return 5
        case .checkbox: return 6
        case .url: return 7
        case .email: return 8
        case .phone: return 9
        case .tag: return 11
        case .object: return 100
        case .unrecognized(let value): return value
        }
    }
}

public extension RelationMetadata.Format {

    var iconName: String {
        switch self {
        case .longText:
            return "longTextType"
        case .shortText:
            return "shortTextType"
        case .number:
            return "numberType"
        case .status:
            return "statusType"
        case .date:
            return "dateType"
        case .file:
            return "fileType"
        case .checkbox:
            return "checkboxType"
        case .url:
            return "urlType"
        case .email:
            return "emailType"
        case .phone:
            return "phoneType"
        case .tag:
            return "tagType"
        case .object:
            return "objectType"
        case .unrecognized(_):
            return "unrecognizedType"
        }
    }
}
