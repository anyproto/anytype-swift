import Foundation

extension Relation {
    
    // For calculated changes in base document
    var dependedObjects: [String] {
        switch self {
        case .text(let text):
            return []
        case .number(let text):
            return []
        case .status(let status):
            return status.values.map(\.id)
        case .date(let date):
            return []
        case .object(let object):
            return object.selectedObjects.map(\.id)
        case .checkbox(let checkbox):
            return []
        case .url(let text):
            return []
        case .email(let text):
            return []
        case .phone(let text):
            return []
        case .tag(let tag):
            return tag.selectedTags.map(\.id)
        case .file(let file):
            return file.files.map(\.id)
        case .unknown(let unknown):
            return []
        }
    }
}
