import Foundation

enum FileObjectError: Error {
    case valueIsEmpty
}

public struct FileObjectId: Hashable {
    
    let value: String
    
    // MARK: - Initializer
    
    init(rawValue: String) throws {
        if rawValue.isEmpty {
            throw FileObjectError.valueIsEmpty
        }
        self.value = rawValue
    }
}
