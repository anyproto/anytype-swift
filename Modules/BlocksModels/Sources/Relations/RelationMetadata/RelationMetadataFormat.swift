import Foundation
import SwiftUI

public extension RelationMetadata {
    
    enum Format: Hashable, CaseIterable {
        case object
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
        case unrecognized
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
        default: self = .unrecognized
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
        case .unrecognized: return -1
        }
    }
}

public extension RelationMetadata.Format {

    var iconName: String {
        switch self {
        case .longText:
            return "format/text"
        case .shortText:
            return "format/text"
        case .number:
            return "format/number"
        case .status:
            return "format/status"
        case .date:
            return "format/date"
        case .file:
            return "format/attachment"
        case .checkbox:
            return "format/checkbox"
        case .url:
            return "format/url"
        case .email:
            return "format/email"
        case .phone:
            return "format/phone"
        case .tag:
            return "format/tag"
        case .object:
            return "format/object"
        case .unrecognized:
            return "format/unknown"
        }
    }

    var name: String {
        switch self {
        case .longText:
            return "Text"
        case .shortText:
            return "Text"
        case .number:
            return "Numbers"
        case .status:
            return "Status"
        case .date:
            return "Date"
        case .file:
            return "File & Media"
        case .checkbox:
            return "Checkbox"
        case .url:
            return "URL"
        case .email:
            return "Email"
        case .phone:
            return "Phone number"
        case .tag:
            return "Tag"
        case .object:
            return "Object"
        case .unrecognized:
            return "Unknown"
        }
    }
}

extension RelationMetadata.Format: Identifiable {

    public var id: Self {
        return self
    }
}
