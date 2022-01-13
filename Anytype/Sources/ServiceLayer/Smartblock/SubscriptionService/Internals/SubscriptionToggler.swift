import ProtobufMessages
import BlocksModels
import AnytypeCore

protocol SubscriptionTogglerProtocol {
    func startSubscription(id: SubscriptionData) -> [ObjectDetails]?
    func stopSubscription(id: SubscriptionId)
}

final class SubscriptionToggler: SubscriptionTogglerProtocol {
    func startSubscription(id: SubscriptionData) -> [ObjectDetails]? {
        switch id {
        case .history:
            return startHistorySubscription()
        case .archive:
            return startArchiveSubscription()
        case .shared:
            return startSharedSubscription()
        case .sets:
            return startSetsSubscription()
        case .profile(id: let profileId):
            return startProfileSubscription(blockId: profileId)
        }
    }
    
    func stopSubscription(id: SubscriptionId) {
        _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [id.rawValue])
    }
    
    // MARK: - Private
    private func startProfileSubscription(blockId: BlockId) -> [ObjectDetails]? {
        let response = Anytype_Rpc.Object.IdsSubscribe.Service.invoke(
            subID: SubscriptionId.profile.rawValue,
            ids: [blockId],
            keys: [BundledRelationKey.id.rawValue, BundledRelationKey.name.rawValue, BundledRelationKey.iconImage.rawValue],
            ignoreWorkspace: ""
        )
        
        guard let result = response.getValue(domain: .subscriptionService) else {
            return nil
        }
        
        return result.records.asDetais
    }
    
    private func startHistorySubscription() -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        var filters = buildFilters(
            isArchived: false,
            typeUrls: ObjectTypeProvider.supportedTypeUrls
        )
        filters.append(SearchHelper.lastOpenedDateNotNilFilter())
        
        return makeRequest(subId: .history, filters: filters, sort: sort)
    }
    
    private func startArchiveSubscription() -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters = buildFilters(
            isArchived: true,
            typeUrls: ObjectTypeProvider.supportedTypeUrls
        )
        
        return makeRequest(subId: .archive, filters: filters, sort: sort)
    }
    
    private func startSharedSubscription() -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        var filters = buildFilters(isArchived: false, typeUrls: ObjectTypeProvider.supportedTypeUrls)
        filters.append(contentsOf: SearchHelper.sharedObjectsFilters())
        
        return makeRequest(subId: .shared, filters: filters, sort: sort)
    }
    
    private func startSetsSubscription() -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        let filters = buildFilters(
            isArchived: false,
            typeUrls: ObjectTypeProvider.objectTypes(smartblockTypes: [.set]).map { $0.url }
        )
        
        return makeRequest(subId: .sets, filters: filters, sort: sort)
    }

    private let homeDetailsKeys: [BundledRelationKey] = [
        .id, .iconEmoji, .iconImage, .name, .snippet, .description, .type, .layout, .isArchived, .isDeleted, .done
    ]
    private func makeRequest(
        subId: SubscriptionData,
        filters: [Anytype_Model_Block.Content.Dataview.Filter],
        sort: Anytype_Model_Block.Content.Dataview.Sort
    ) -> [ObjectDetails]? {
        let response = Anytype_Rpc.Object.SearchSubscribe.Service.invoke(
            subID: subId.identifier.rawValue,
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
        
        return result.records.asDetais
    }
    
    private func buildFilters(isArchived: Bool, typeUrls: [String]) -> [Anytype_Model_Block.Content.Dataview.Filter] {
        [
            SearchHelper.notHiddenFilter(),
            
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            
            SearchHelper.typeFilter(typeUrls: typeUrls)
        ]
    }
}
