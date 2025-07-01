import Foundation

extension Property {
    
    // For calculated changes in base document
    var dependedObjects: [String] {
        switch self {
        case .text, .number, .date, .checkbox, .url, .email, .phone, .unknown:
            return []
        case .status(let status):
            return status.values.map(\.id)
        case .object(let object):
            return object.selectedObjects.map(\.id)
        case .tag(let tag):
            return tag.selectedTags.map(\.id)
        case .file(let file):
            return file.files.map(\.id)
        }
    }
}
