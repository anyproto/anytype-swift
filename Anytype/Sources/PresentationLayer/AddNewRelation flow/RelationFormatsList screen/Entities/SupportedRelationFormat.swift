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

    var iconAsset: ImageAsset {
        switch self {
        case .text: return RelationMetadata.Format.longText.iconAsset
        case .tag: return RelationMetadata.Format.tag.iconAsset
        case .status:  return RelationMetadata.Format.status.iconAsset
        case .number:  return RelationMetadata.Format.number.iconAsset
        case .date:  return RelationMetadata.Format.date.iconAsset
        case .file:  return RelationMetadata.Format.file.iconAsset
        case .object:  return RelationMetadata.Format.object.iconAsset
        case .checkbox: return RelationMetadata.Format.checkbox.iconAsset
        case .url:  return RelationMetadata.Format.url.iconAsset
        case .email: return RelationMetadata.Format.email.iconAsset
        case .phone: return RelationMetadata.Format.phone.iconAsset
        }
    }

    var title: String {
        switch self {
        case .text: return Loc.text
        case .number: return Loc.numbers
        case .status: return Loc.status
        case .date: return Loc.date
        case .file: return Loc.fileMedia
        case .checkbox: return Loc.checkbox
        case .url: return Loc.url
        case .email: return Loc.email
        case .phone: return Loc.phoneNumber
        case .tag: return Loc.tag
        case .object: return Loc.object
        }
    }
}
