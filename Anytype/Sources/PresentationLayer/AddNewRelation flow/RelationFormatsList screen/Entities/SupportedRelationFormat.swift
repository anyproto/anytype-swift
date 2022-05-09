import Foundation
import BlocksModels

enum SupportedRelationFormat: String, Hashable, CaseIterable {
    case object
    case text
    case number
    case status
    case tag
    case date
    case file
    case checkbox
    case url
    case email
    case phone
}

extension SupportedRelationFormat: Identifiable {
    
    var id: String { self.rawValue }
    
}

extension SupportedRelationFormat {

    var icon: String {
        switch self {
        case .text: return RelationMetadata.Format.longText.iconName
        case .tag: return RelationMetadata.Format.tag.iconName
        case .status:  return RelationMetadata.Format.status.iconName
        case .number:  return RelationMetadata.Format.number.iconName
        case .date:  return RelationMetadata.Format.date.iconName
        case .file:  return RelationMetadata.Format.file.iconName
        case .object:  return RelationMetadata.Format.object.iconName
        case .checkbox: return RelationMetadata.Format.checkbox.iconName
        case .url:  return RelationMetadata.Format.url.iconName
        case .email: return RelationMetadata.Format.email.iconName
        case .phone: return RelationMetadata.Format.phone.iconName
        }
    }

    var title: String {
        switch self {
        case .text: return "Text".localized
        case .number: return "Numbers".localized
        case .status: return "Status".localized
        case .date: return "Date".localized
        case .file: return "File & Media".localized
        case .checkbox: return "Checkbox".localized
        case .url: return "URL".localized
        case .email: return "Email".localized
        case .phone: return "Phone number".localized
        case .tag: return "Tag".localized
        case .object: return "Object".localized
        }
    }
}
