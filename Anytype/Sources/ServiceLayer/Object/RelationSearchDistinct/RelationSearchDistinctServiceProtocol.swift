import BlocksModels

protocol RelationSearchDistinctServiceProtocol {
    func searchDistinct(relationKey: String, filters: [DataviewFilter]) async throws -> [DataviewGroup]
}
