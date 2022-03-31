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
    
}

extension Relation {
    
    var iconName: String {
        switch self {
        case .text: return RelationMetadata.Format.longText.iconName
        case .number: return RelationMetadata.Format.number.iconName
        case .status: return RelationMetadata.Format.status.iconName
        case .date: return RelationMetadata.Format.date.iconName
        case .object: return RelationMetadata.Format.object.iconName
        case .checkbox: return RelationMetadata.Format.checkbox.iconName
        case .url: return RelationMetadata.Format.url.iconName
        case .email: return RelationMetadata.Format.email.iconName
        case .phone: return RelationMetadata.Format.phone.iconName
        case .tag: return RelationMetadata.Format.tag.iconName
        case .file: return RelationMetadata.Format.file.iconName
        case .unknown: return RelationMetadata.Format.unrecognized.iconName
        }
    }
    
}

// MARK: - hint

extension Relation {
    
    var hint: String {
        switch self {
        case .text: return "Enter text".localized
        case .number: return "Enter number".localized
        case .date: return "Enter date".localized
        case .object: return "Select objects".localized
        case .url: return "Enter URL".localized
        case .email: return "Enter e-mail".localized
        case .phone: return "Enter phone".localized
        case .status: return "Select status".localized
        case .tag: return "Select tags".localized
        case .file: return "Select files".localized
        case .checkbox: return ""
        case .unknown: return "Enter value".localized
        }
    }
    
}
