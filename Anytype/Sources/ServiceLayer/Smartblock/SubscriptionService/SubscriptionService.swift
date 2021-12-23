import ProtobufMessages
import BlocksModels
import AnytypeCore

protocol SubscriptionServiceProtocol {
    func toggleHistorySubscription(_ turnOn: Bool) -> [ObjectDetails]?
}

final class SubscriptionService: SubscriptionServiceProtocol {
    func toggleHistorySubscription(_ turnOn: Bool) -> [ObjectDetails]? {
        guard turnOn else {
            _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [SubscriptionId.history.rawValue])
            return nil
        }
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        let filters = buildFilters(
            isArchived: false,
            typeUrls: ObjectTypeProvider.supportedTypeUrls
        )
        
        return makeRequest(subId: SubscriptionId.history.rawValue, filters: filters, sort: sort)
    }
    
    let homeDetailsKeys = ["id", "icon", "iconImage", "iconEmoji", "name", "snippet", "description", "type", "layout", "isArchived", "isDeleted", "isDone" ]
    private func makeRequest(
        subId: String,
        filters: [Anytype_Model_Block.Content.Dataview.Filter],
        sort: Anytype_Model_Block.Content.Dataview.Sort
    ) -> [ObjectDetails]? {
        let response = Anytype_Rpc.Object.SearchSubscribe.Service.invoke(
            subID: subId,
            filters: filters,
            sorts: [sort],
            fullText: "",
            limit: 100,
            offset: 0,
            keys: homeDetailsKeys,
            afterID: "",
            beforeID: "",
            source: [],
            ignoreWorkspace: ""
        )
        
        guard let result = response.getValue(domain: .subscriptionService) else {
            return nil
        }
        
        return result.records.map(\.fields).compactMap { fields in
            guard let id = fields["id"]?.stringValue else {
                anytypeAssertionFailure("Empty id in sybscription data \(fields)", domain: .subscriptionService)
                return nil
            }
            
            return ObjectDetails(id: id, values: fields)
        }
    }
    
    private func buildFilters(isArchived: Bool, typeUrls: [String]) -> [Anytype_Model_Block.Content.Dataview.Filter] {
        [
            SearchHelper.notHiddenFilter(),
            
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            
            SearchHelper.typeFilter(typeUrls: typeUrls)
        ]
    }
}
