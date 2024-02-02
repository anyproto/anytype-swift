import Foundation

public struct FileDetails {
    
    public var id: String
    public var name: String
    
    init(objectDetails: ObjectDetails) {
        self.id = objectDetails.id
        self.name = objectDetails.name
    }
}
