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
        case .text: return RelationFormat.longText.iconAsset
        case .tag: return RelationFormat.tag.iconAsset
        case .status:  return RelationFormat.status.iconAsset
        case .number:  return RelationFormat.number.iconAsset
        case .date:  return RelationFormat.date.iconAsset
        case .file:  return RelationFormat.file.iconAsset
        case .object:  return RelationFormat.object.iconAsset
        case .checkbox: return RelationFormat.checkbox.iconAsset
        case .url:  return RelationFormat.url.iconAsset
        case .email: return RelationFormat.email.iconAsset
        case .phone: return RelationFormat.phone.iconAsset
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
