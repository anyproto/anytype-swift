import Foundation

public protocol ParticipantServiceProtocol: AnyObject {
    func searchParticipants(spaceId: String) async throws -> [Participant]
}

final class ParticipantService: ParticipantServiceProtocol {
    
    @Injected(\.searchMiddleService)
    private var searchService: SearchMiddleServiceProtocol
    
    func searchParticipants(spaceId: String) async throws -> [Participant] {
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.spaceId(spaceId)
            SearchHelper.layoutFilter([.participant])
        }
        
        let data = SearchRequest(filters: filters, sorts: [], fullText: "", keys: Participant.subscriptionKeys.map(\.rawValue), limit: 0)
        let details = try await searchService.search(data: data)
        return details.compactMap { try? Participant(details: $0) }
    }
}
