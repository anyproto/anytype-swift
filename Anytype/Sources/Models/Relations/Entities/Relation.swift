import Foundation
import Services

enum Relation: Hashable, Identifiable, Sendable {
    case text(Text)
    case number(Text)
    case status(Status)
    case date(Date)
    case object(Object)
    case checkbox(Checkbox)
    case url(Text)
    case email(Text)
    case phone(Text)
    case tag(Tag)
    case file(File)
    case unknown(Unknown)
}

// MARK: - RelationValueProtocol

extension Relation: PropertyProtocol {
    
    var id: String {
        switch self {
        case .text(let text): return text.id
        case .number(let text): return text.id
        case .status(let status): return status.id
        case .date(let date): return date.id
        case .object(let object): return object.id
        case .checkbox(let checkbox): return checkbox.id
        case .url(let text): return text.id
        case .email(let text): return text.id
        case .phone(let text): return text.id
        case .tag(let tag): return tag.id
        case .file(let file): return file.id
        case .unknown(let unknown): return unknown.id
        }
    }
    
    var key: String {
        switch self {
        case .text(let text): return text.key
        case .number(let text): return text.key
        case .status(let status): return status.key
        case .date(let date): return date.key
        case .object(let object): return object.key
        case .checkbox(let checkbox): return checkbox.key
        case .url(let text): return text.key
        case .email(let text): return text.key
        case .phone(let text): return text.key
        case .tag(let tag): return tag.key
        case .file(let file): return file.key
        case .unknown(let unknown): return unknown.key
        }
    }
    
    var name: String {
        switch self {
        case .text(let text): return text.name
        case .number(let text): return text.name
        case .status(let status): return status.name
        case .date(let date): return date.name
        case .object(let object): return object.name
        case .checkbox(let checkbox): return checkbox.name
        case .url(let text): return text.name
        case .email(let text): return text.name
        case .phone(let text): return text.name
        case .tag(let tag): return tag.name
        case .file(let file): return file.name
        case .unknown(let unknown): return unknown.name
        }
    }
    
    var iconAsset: ImageAsset {
        switch self {
        case .text: return PropertyFormat.longText.iconAsset
        case .tag: return PropertyFormat.tag.iconAsset
        case .status:  return PropertyFormat.status.iconAsset
        case .number:  return PropertyFormat.number.iconAsset
        case .date:  return PropertyFormat.date.iconAsset
        case .file:  return PropertyFormat.file.iconAsset
        case .object:  return PropertyFormat.object.iconAsset
        case .checkbox: return PropertyFormat.checkbox.iconAsset
        case .url:  return PropertyFormat.url.iconAsset
        case .email: return PropertyFormat.email.iconAsset
        case .phone: return PropertyFormat.phone.iconAsset
        case .unknown: return PropertyFormat.unrecognized.iconAsset
        }
    }
    
    var isEditable: Bool {
        switch self {
        case .text(let text): return text.isEditable
        case .number(let text): return text.isEditable
        case .status(let status): return status.isEditable
        case .date(let date): return date.isEditable
        case .object(let object): return object.isEditable
        case .checkbox(let checkbox): return checkbox.isEditable
        case .url(let text): return text.isEditable
        case .email(let text): return text.isEditable
        case .phone(let text): return text.isEditable
        case .tag(let tag): return tag.isEditable
        case .file(let file): return file.isEditable
        case .unknown(let unknown): return unknown.isEditable
        }
    }
    
    var canBeRemovedFromObject: Bool {
        switch self {
        case .text(let text): return text.canBeRemovedFromObject
        case .number(let text): return text.canBeRemovedFromObject
        case .status(let status): return status.canBeRemovedFromObject
        case .date(let date): return date.canBeRemovedFromObject
        case .object(let object): return object.canBeRemovedFromObject
        case .checkbox(let checkbox): return checkbox.canBeRemovedFromObject
        case .url(let text): return text.canBeRemovedFromObject
        case .email(let text): return text.canBeRemovedFromObject
        case .phone(let text): return text.canBeRemovedFromObject
        case .tag(let tag): return tag.canBeRemovedFromObject
        case .file(let file): return file.canBeRemovedFromObject
        case .unknown(let unknown): return unknown.canBeRemovedFromObject
        }
    }
    
    var isFeatured: Bool {
        switch self {
        case .text(let text): return text.isFeatured
        case .number(let text): return text.isFeatured
        case .status(let status): return status.isFeatured
        case .date(let date): return date.isFeatured
        case .object(let object): return object.isFeatured
        case .checkbox(let checkbox): return checkbox.isFeatured
        case .url(let text): return text.isFeatured
        case .email(let text): return text.isFeatured
        case .phone(let text): return text.isFeatured
        case .tag(let tag): return tag.isFeatured
        case .file(let file): return file.isFeatured
        case .unknown(let unknown): return unknown.isFeatured
        }
    }
    
    var hasValue: Bool {
        switch self {
        case .text(let text): return text.hasValue
        case .number(let text): return text.hasValue
        case .status(let status): return status.hasValue
        case .date(let date): return date.hasValue
        case .object(let object): return object.hasValue
        case .checkbox(let checkbox): return checkbox.hasValue
        case .url(let text): return text.hasValue
        case .email(let text): return text.hasValue
        case .phone(let text): return text.hasValue
        case .tag(let tag): return tag.hasValue
        case .file(let file): return file.hasValue
        case .unknown(let unknown): return unknown.hasValue
        }
    }
    
    var isSource: Bool {
        return key == BundledPropertyKey.source.rawValue
    }
    
    var isDeleted: Bool {
        switch self {
        case .text(let text): return text.isDeleted
        case .number(let text): return text.isDeleted
        case .status(let status): return status.isDeleted
        case .date(let date): return date.isDeleted
        case .object(let object): return object.isDeleted
        case .checkbox(let checkbox): return checkbox.isDeleted
        case .url(let text): return text.isDeleted
        case .email(let text): return text.isDeleted
        case .phone(let text): return text.isDeleted
        case .tag(let tag): return tag.isDeleted
        case .file(let file): return file.isDeleted
        case .unknown(let unknown): return unknown.isDeleted
        }
    }
    
    var editableRelation: Relation? {
        switch self {
        case .object(let object):
            var editableObject = object
            editableObject.isEditable = true
            return Relation.object(editableObject)
        default:
            return nil
        }
    }
    
    var format: SupportedPropertyFormat? {
        switch self {
        case .text:
            .text
        case .number:
            .number
        case .status:
            .status
        case .date:
            .date
        case .object:
            .object
        case .checkbox:
            .checkbox
        case .url:
            .url
        case .email:
            .email
        case .phone:
            .phone
        case .tag:
            .tag
        case .file:
            .file
        case .unknown:
            nil
        }
    }
    
    var limitedObjectTypes: [String]? {
        switch self {
        case .object(let object):
            object.limitedObjectTypes
        case .text, .number, .status, .date, .checkbox, .url, .email, .phone, .tag, .file, .unknown:
            nil
        }
    }
}
