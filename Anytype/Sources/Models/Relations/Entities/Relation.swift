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

// MARK: - RelationProtocol

extension Relation: RelationProtocol {
    
    var id: String { key }
    
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
    
    var isBundled: Bool {
        switch self {
        case .text(let text): return text.isBundled
        case .number(let text): return text.isBundled
        case .status(let status): return status.isBundled
        case .date(let date): return date.isBundled
        case .object(let object): return object.isBundled
        case .checkbox(let checkbox): return checkbox.isBundled
        case .url(let text): return text.isBundled
        case .email(let text): return text.isBundled
        case .phone(let text): return text.isBundled
        case .tag(let tag): return tag.isBundled
        case .file(let file): return file.isBundled
        case .unknown(let unknown): return unknown.isBundled
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
        case .text(let text): return (text.value ?? "").isNotEmpty
        case .number(let text): return (text.value ?? "").isNotEmpty
        case .status(let status): return status.values.isNotEmpty
        case .date(let date): return date.value != nil
        case .object(let object): return object.selectedObjects.isNotEmpty
        case .checkbox: return true
        case .url(let text): return (text.value ?? "").isNotEmpty
        case .email(let text): return (text.value ?? "").isNotEmpty
        case .phone(let text): return (text.value ?? "").isNotEmpty
        case .tag(let tag): return tag.selectedTags.isNotEmpty
        case .file(let file): return file.files.isNotEmpty
        case .unknown(let unknown): return unknown.value.isNotEmpty
        }
    }
}
