import Foundation

extension Relation {
    
    // For calculated changes in base document
    var dependedObjects: [String] {
        switch self {
        case .text:
            return []
        case .number:
            return []
        case .status(let status):
            return status.values.map(\.id)
        case .date:
            return []
        case .object(let object):
            return object.selectedObjects.map(\.id)
        case .checkbox:
            return []
        case .url:
            return []
        case .email:
            return []
        case .phone:
            return []
        case .tag(let tag):
            return tag.selectedTags.map(\.id)
        case .file(let file):
            return file.files.map(\.id)
        case .unknown:
            return []
        }
    }
}
