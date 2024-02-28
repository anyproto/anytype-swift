import Foundation

protocol ParticipantServiceProtocol: AnyObject {
    
    private let searchService: SearchMiddleServiceProtocol
    
    
    
    func search(spaceId: String, identityId: String) async throws -> Participant {
        
    }
}
