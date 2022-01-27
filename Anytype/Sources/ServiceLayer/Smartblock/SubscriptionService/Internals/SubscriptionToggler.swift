import ProtobufMessages
import BlocksModels
import AnytypeCore

protocol SubscriptionTogglerProtocol {
    func startSubscription(data: SubscriptionData) -> [ObjectDetails]?
    func stopSubscription(id: SubscriptionId)
}

final class SubscriptionToggler: SubscriptionTogglerProtocol {
    func startSubscription(data: SubscriptionData) -> [ObjectDetails]? {
        switch data {
        case .historyTab:
            return startHistorySubscription()
        case .archiveTab:
            return startArchiveSubscription()
        case .sharedTab:
            return startSharedSubscription()
        case .setsTab:
            return startSetsSubscription()
        case .profile(id: let profileId):
            return startProfileSubscription(blockId: profileId)
        case let .set(source: source, sorts: sorts, filters: filterts, relations: relations):
            return startSetSubscription(source: source, sorts: sorts, filters: filterts, relations: relations)
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
    
    private func startSetSubscription(
        source: [String],
        sorts: [DataviewSort],
        filters: [DataviewFilter],
        relations: [DataviewViewRelation]
    ) -> [ObjectDetails]? {
        var keys = relations.map { $0.key }
        keys.append(contentsOf: homeDetailsKeys.map { $0.rawValue} )
        
        return makeRequest(subId: .set, filters: filters, sorts: sorts, source: source, keys: keys)
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
        
        return makeRequest(subId: .historyTab, filters: filters, sorts: [sort])
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
        
        return makeRequest(subId: .archiveTab, filters: filters, sorts: [sort])
    }
    
    private func startSharedSubscription() -> [ObjectDetails]? {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        var filters = buildFilters(isArchived: false, typeUrls: ObjectTypeProvider.supportedTypeUrls)
        filters.append(contentsOf: SearchHelper.sharedObjectsFilters())
        
        return makeRequest(subId: .sharedTab, filters: filters, sorts: [sort])
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
        
        return makeRequest(subId: .setsTab, filters: filters, sorts: [sort])
    }

    private let homeDetailsKeys: [BundledRelationKey] = [
        .id, .iconEmoji, .iconImage, .name, .snippet, .description, .type, .layout, .isArchived, .isDeleted, .done
    ]
    private func makeRequest(
        subId: SubscriptionId,
        filters: [DataviewFilter],
        sorts: [DataviewSort],
        source: [String] = [],
        keys: [String]? = nil
    ) -> [ObjectDetails]? {
        let response = Anytype_Rpc.Object.SearchSubscribe.Service.invoke(
            subID: subId.rawValue,
            filters: filters,
            sorts: sorts,
            fullText: "",
            limit: 50,
            offset: 0,
            keys: keys ?? homeDetailsKeys.map { $0.rawValue },
            afterID: "",
            beforeID: "",
            source: source,
            ignoreWorkspace: ""
        )
        
        guard let result = response.getValue(domain: .subscriptionService) else {
            return nil
        }
        
        return result.records.asDetais
    }
    
    private func buildFilters(isArchived: Bool, typeUrls: [String]) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            
            SearchHelper.typeFilter(typeUrls: typeUrls)
        ]
    }
}
