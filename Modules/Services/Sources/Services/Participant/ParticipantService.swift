import Foundation

public protocol ParticipantServiceProtocol: AnyObject {
    func searchParticipant(spaceId: String, prifileObjectId: String) async throws -> Participant
}

public final class ParticipantService: ParticipantServiceProtocol {
    
    private let searchMiddleService: SearchMiddleServiceProtocol
    
    public init(searchMiddleService: SearchMiddleServiceProtocol) {
        self.searchMiddleService = searchMiddleService
    }
    
    // MARK: - ParticipantServiceProtocol
    
    public func searchParticipant(spaceId: String, prifileObjectId: String) async throws -> Participant {
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.layoutFilter([DetailsLayout.participant])
            SearchHelper.spaceId(spaceId)
            SearchHelper.identityProfileLink(prifileObjectId)
        }
        
        let result = try await searchMiddleService.search(filters: filters, limit: 1)
        
        guard let details = result.first else {
            throw CommonError.undefined
        }
        
        return try Participant(details: details)
    }
}
