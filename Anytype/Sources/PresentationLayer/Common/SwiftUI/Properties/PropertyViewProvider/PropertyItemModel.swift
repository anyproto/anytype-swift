import Services

enum PropertyItemModel: Hashable {
    case text(Property.Text)
    case number(Property.Text)
    case status(Property.Status)
    case date(Property.Date)
    case object(Property.Object)
    case checkbox(Property.Checkbox)
    case url(Property.Text)
    case email(Property.Text)
    case phone(Property.Text)
    case tag(Property.Tag)
    case file(Property.File)
    case unknown(Property.Unknown)

    init(property: Property) {
        switch property {
        case .text(let text):
            self = .text(text)
        case .number(let text):
            self = .number(text)
        case .status(let status):
            self = .status(status)
        case .date(let date):
            self = .date(date)
        case .object(let object):
            self = .object(object)
        case .checkbox(let checkbox):
            self = .checkbox(checkbox)
        case .url(let text):
            self = .url(text)
        case .email(let text):
            self = .email(text)
        case .phone(let text):
            self = .phone(text)
        case .tag(let tag):
            self = .tag(tag)
        case .file(let file):
            self = .file(file)
        case .unknown(let unknown):
            self = .unknown(unknown)
        }
    }

    var hint: String {
        switch self {
        case .text: return Loc.enterText
        case .number: return Loc.enterNumber
        case .date: return Loc.selectDate
        case .object:
            switch key {
            case BundledPropertyKey.setOf.rawValue:
                return Loc.Set.FeaturedRelations.query
            default:
                return Loc.selectObject
            }
        case .url: return Loc.addLink
        case .email: return Loc.addEmail
        case .phone: return Loc.addPhone
        case .status: return Loc.selectOption
        case .tag: return Loc.selectOptions
        case .file: return Loc.selectFile
        case .checkbox: return ""
        case .unknown: return Loc.enterValue
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
    
    var isErrorState: Bool {
        switch self {
        case let .text(text): return text.isDeletedValue
        case let .object(object): return
            (object.key == BundledPropertyKey.setOf.rawValue && object.isDeletedValue)
            || (object.key == BundledPropertyKey.type.rawValue && object.isDeletedValue)
        default:
            return false
        }
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
    
    var links: Property.Object.Links? {
        switch self {
        case .object(let object): 
            return object.links
        default: 
            return nil
        }
    }
}
