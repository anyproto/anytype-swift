import Foundation

@MainActor
final class AllContentCoordinatorViewModel: ObservableObject {
    
    let spaceId: String
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
}
