import ProtobufMessages
import BlocksModels
import AnytypeCore

protocol SubscriptionServiceProtocol {
    func toggleSubscription(id: SubscriptionId, _ turnOn: Bool) -> [ObjectDetails]?
}

final class SubscriptionService: SubscriptionServiceProtocol {
    func toggleSubscription(id: SubscriptionId, _ turnOn: Bool) -> [ObjectDetails]? {
        switch id {
        case .history:
            return toggleHistorySubscription(turnOn)
        case .archive:
            return toggleArchiveSubscription(turnOn)
        case .shared:
            return toggleSharedSubscription(turnOn)
        case .sets:
            return toggleSetsSubscription(turnOn)
        }
    }
    
    // MARK: - Private
    private func toggleHistorySubscription(_ turnOn: Bool) -> [ObjectDetails]? {
        guard turnOn else {
            _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [SubscriptionId.history.rawValue])
            return nil
        }
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        var filters = buildFilters(
            isArchived: false,
            typeUrls: ObjectTypeProvider.supportedTypeUrls
        )
        filters.append(SearchHelper.lastOpenedDateNotNilFilter())
        
        return makeRequest(subId: SubscriptionId.history.rawValue, filters: filters, sort: sort)
    }
    
    private func toggleArchiveSubscription(_ turnOn: Bool) -> [ObjectDetails]? {
        guard turnOn else {
            _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [SubscriptionId.archive.rawValue])
            return nil
        }
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters = buildFilters(
            isArchived: true,
            typeUrls: ObjectTypeProvider.supportedTypeUrls
        )
        
        return makeRequest(subId: SubscriptionId.archive.rawValue, filters: filters, sort: sort)
    }
    
    private func toggleSharedSubscription(_ turnOn: Bool) -> [ObjectDetails]? {
        guard turnOn else {
            _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [SubscriptionId.shared.rawValue])
            return nil
        }
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        var filters = buildFilters(isArchived: false, typeUrls: ObjectTypeProvider.supportedTypeUrls)
        filters.append(contentsOf: SearchHelper.sharedObjectsFilters())
        
        return makeRequest(subId: SubscriptionId.shared.rawValue, filters: filters, sort: sort)
    }
    
    private func toggleSetsSubscription(_ turnOn: Bool) -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        let filters = buildFilters(
            isArchived: false,
            typeUrls: ObjectTypeProvider.objectTypes(smartblockTypes: [.set]).map { $0.url }
        )
        
        return makeRequest(subId: SubscriptionId.sets.rawValue, filters: filters, sort: sort)
    }

    private let homeDetailsKeys: [BundledRelationKey] = [
        .id, .iconEmoji, .iconImage, .name, .snippet, .description, .type, .layout, .isArchived, .isDeleted, .done
    ]
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
            keys: homeDetailsKeys.map { $0.rawValue },
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
