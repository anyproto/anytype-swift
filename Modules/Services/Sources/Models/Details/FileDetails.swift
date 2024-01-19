import Foundation

public struct FileDetails {
    
    public var name: String { objectDetails.name }
    public var id: String { objectDetails.id }
    
    private let objectDetails: ObjectDetails
    
    init(objectDetails: ObjectDetails) {
        self.objectDetails = objectDetails
    }
}
