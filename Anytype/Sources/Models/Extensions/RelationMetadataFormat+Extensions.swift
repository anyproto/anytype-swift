import Foundation
import Services

extension RelationFormat {

    var iconAsset: ImageAsset {
        switch self {
        case .longText:
            return .Format.text
        case .shortText:
            return .Format.name
        case .number:
            return .Format.number
        case .status:
            return .Format.status
        case .date:
            return .Format.date
        case .file:
            return .Format.attachment
        case .checkbox:
            return .Format.checkbox
        case .url:
            return .Format.url
        case .email:
            return .Format.email
        case .phone:
            return .Format.phone
        case .tag:
            return .Format.tag
        case .object:
            return .Format.object
        case .unrecognized:
            return .Format.unknown
        }
    }
    
    var name: String {
        switch self {
        case .longText: return "Text"
        case .shortText: return "Text"
        case .number: return "Numbers"
        case .status: return "Status"
        case .date: return "Date"
        case .file: return "File & Media"
        case .checkbox: return "Checkbox"
        case .url: return "URL"
        case .email: return "Email"
        case .phone: return "Phone number"
        case .tag: return "Tag"
        case .object: return "Object"
        case .unrecognized: return "Unknown"
        }
    }

}
