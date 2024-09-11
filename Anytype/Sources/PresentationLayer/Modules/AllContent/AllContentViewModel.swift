import Foundation

@MainActor
final class AllContentViewModel: ObservableObject {
    
    private let spaceId: String
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
}
