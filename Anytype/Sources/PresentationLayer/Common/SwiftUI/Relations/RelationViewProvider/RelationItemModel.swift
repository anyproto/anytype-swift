import BlocksModels

enum RelationItemModel: Hashable {
    case text(RelationValue.Text)
    case number(RelationValue.Text)
    case status(RelationValue.Status)
    case date(DateModel)
    case object(RelationValue.Object)
    case checkbox(RelationValue.Checkbox)
    case url(RelationValue.Text)
    case email(RelationValue.Text)
    case phone(RelationValue.Text)
    case tag(RelationValue.Tag)
    case file(RelationValue.File)
    case unknown(RelationValue.Unknown)

    init(relationValue: RelationValue) {
        switch relationValue {
        case .text(let text):
            self = .text(text)
        case .number(let text):
            self = .number(text)
        case .status(let status):
            self = .status(status)
        case .date(let date):
            self = .date(
                .init(
                    key: date.key,
                    name: date.name,
                    textValue: date.value?.text,
                    isEditable: relationValue.isEditable
                )
            )
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
        case .date: return Loc.enterDate
        case .object:
            switch key {
            case BundledRelationKey.setOf.rawValue:
                return Loc.Set.FeaturedRelations.source
            default:
                return Loc.selectObjects
            }
        case .url: return Loc.enterURL
        case .email: return Loc.enterEMail
        case .phone: return Loc.enterPhone
        case .status: return Loc.selectStatus
        case .tag: return Loc.selectTags
        case .file: return Loc.selectFiles
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
}

extension RelationItemModel {
    struct DateModel: Hashable {
        let key: String
        let name: String
        let textValue: String?
        let isEditable: Bool
    }
}
