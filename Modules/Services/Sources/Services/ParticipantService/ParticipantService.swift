import Foundation

public protocol ParticipantServiceProtocol: AnyObject, Sendable {
    func searchParticipants(spaceId: String) async throws -> [Participant]
    func searchParticipant(spaceId: String, identity: String) async throws -> Participant?
}

final class ParticipantService: ParticipantServiceProtocol {
    
    private let searchService: any SearchMiddleServiceProtocol = Container.shared.searchMiddleService()
    
    func searchParticipants(spaceId: String) async throws -> [Participant] {
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.layoutFilter([.participant])
        }
        
        let data = SearchRequest(spaceId: spaceId, filters: filters, sorts: [], fullText: "", keys: Participant.subscriptionKeys.map(\.rawValue), limit: 0)
        let details = try await searchService.search(data: data)
        return details.compactMap { try? Participant(details: $0) }
    }
    
    func searchParticipant(spaceId: String, identity: String) async throws -> Participant? {
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.layoutFilter([.participant])
            SearchHelper.identity(identity)
        }
        
        let data = SearchRequest(spaceId: spaceId, filters: filters, sorts: [], fullText: "", keys: Participant.subscriptionKeys.map(\.rawValue), limit: 0)
        let details = try await searchService.search(data: data)
        return details.compactMap { try? Participant(details: $0) }.first
    }

}
