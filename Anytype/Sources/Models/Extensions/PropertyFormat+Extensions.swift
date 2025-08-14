import Foundation
import Services

extension PropertyFormat {

    var iconAsset: ImageAsset {
        switch self {
        case .longText:
            return .X24.text
        case .shortText:
            return .X24.name
        case .number:
            return .X24.number
        case .status:
            return .X24.select
        case .date:
            return .X24.date
        case .file:
            return .X24.attachment
        case .checkbox:
            return .X24.checkbox
        case .url:
            return .X24.url
        case .email:
            return .X24.email
        case .phone:
            return .X24.phoneNumber
        case .tag:
            return .X24.multiselect
        case .object:
            return .X24.object
        case .unrecognized:
            return .Format.unknown
        }
    }
    
    var analyticsName: String {
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
