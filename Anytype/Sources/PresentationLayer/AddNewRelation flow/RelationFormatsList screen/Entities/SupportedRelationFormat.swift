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
        case .text: return Loc.text
        case .number: return Loc.numbers
        case .status: return Loc.status
        case .date: return Loc.date
        case .file: return "File & Media".localized
        case .checkbox: return Loc.checkbox
        case .url: return Loc.url
        case .email: return Loc.email
        case .phone: return Loc.phoneNumber
        case .tag: return Loc.tag
        case .object: return Loc.object
        }
    }
}
