import BlocksModels
import ProtobufMessages

final class RelationSearchDistinctService: RelationSearchDistinctServiceProtocol {
    func searchDistinct(relationKey: String, filters: [DataviewFilter]) async throws -> [DataviewGroup] {
        return []
//        let response = try await Anytype_Rpc.Object.RelationSearchDistinct.Service
//            .invocation(
//                relationKey: relationKey,
//                filters: filters
//            )
//            .invoke(errorDomain: .relationSearchDistinctService)
//        return response.groups
    }
}
