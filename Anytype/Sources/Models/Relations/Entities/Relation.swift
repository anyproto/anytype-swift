import Foundation
import BlocksModels

enum Relation: Hashable, Identifiable {
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

extension Relation: RelationProtocol {
    
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
    
    var isSystem: Bool {
        switch self {
        case .text(let text): return text.isSystem
        case .number(let text): return text.isSystem
        case .status(let status): return status.isSystem
        case .date(let date): return date.isSystem
        case .object(let object): return object.isSystem
        case .checkbox(let checkbox): return checkbox.isSystem
        case .url(let text): return text.isSystem
        case .email(let text): return text.isSystem
        case .phone(let text): return text.isSystem
        case .tag(let tag): return tag.isSystem
        case .file(let file): return file.isSystem
        case .unknown(let unknown): return unknown.isSystem
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
    
    var hasDetails: Bool {
        switch self {
        case .text: return true
        case .number: return true
        case .status: return true
        case .date: return false
        case .object: return true
        case .checkbox: return false
        case .url: return true
        case .email: return true
        case .phone: return true
        case .tag: return true
        case .file: return true
        case .unknown: return false
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
        return key == BundledRelationKey.source.rawValue
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
}
