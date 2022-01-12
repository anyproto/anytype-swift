import ProtobufMessages
import BlocksModels
import AnytypeCore

protocol SubscriptionTogglerProtocol {
    func toggleSubscription(id: SubscriptionId, _ turnOn: Bool) -> [ObjectDetails]?
}

final class SubscriptionToggler: SubscriptionTogglerProtocol {
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
        case .profile(id: let profileId):
            return toggleIdSubscription(turnOn, blockId: profileId)
        }
    }
    
    // MARK: - Private
    private func toggleIdSubscription(_ turnOn: Bool, blockId: BlockId) -> [ObjectDetails]? {
        guard turnOn else {
            _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [SubscriptionId.profile(id: blockId).identifier])
            return nil
        }
        
        let response = Anytype_Rpc.Object.IdsSubscribe.Service.invoke(
            subID: SubscriptionId.profile(id: blockId).identifier,
            ids: [blockId],
            keys: [BundledRelationKey.id.rawValue, BundledRelationKey.name.rawValue, BundledRelationKey.iconImage.rawValue],
            ignoreWorkspace: ""
        )
        
        guard let result = response.getValue(domain: .subscriptionService) else {
            return nil
        }
        
        return result.records.asDetais
    }
    
    private func toggleHistorySubscription(_ turnOn: Bool) -> [ObjectDetails]? {
        guard turnOn else {
            _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [SubscriptionId.history.identifier])
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
        
        return makeRequest(subId: .history, filters: filters, sort: sort)
    }
    
    private func toggleArchiveSubscription(_ turnOn: Bool) -> [ObjectDetails]? {
        guard turnOn else {
            _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [SubscriptionId.archive.identifier])
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
        
        return makeRequest(subId: .archive, filters: filters, sort: sort)
    }
    
    private func toggleSharedSubscription(_ turnOn: Bool) -> [ObjectDetails]? {
        guard turnOn else {
            _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [SubscriptionId.shared.identifier])
            return nil
        }
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        var filters = buildFilters(isArchived: false, typeUrls: ObjectTypeProvider.supportedTypeUrls)
        filters.append(contentsOf: SearchHelper.sharedObjectsFilters())
        
        return makeRequest(subId: .shared, filters: filters, sort: sort)
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
        
        return makeRequest(subId: .sets, filters: filters, sort: sort)
    }

    private let homeDetailsKeys: [BundledRelationKey] = [
        .id, .iconEmoji, .iconImage, .name, .snippet, .description, .type, .layout, .isArchived, .isDeleted, .done
    ]
    private func makeRequest(
        subId: SubscriptionId,
        filters: [Anytype_Model_Block.Content.Dataview.Filter],
        sort: Anytype_Model_Block.Content.Dataview.Sort
    ) -> [ObjectDetails]? {
        let response = Anytype_Rpc.Object.SearchSubscribe.Service.invoke(
            subID: subId.identifier,
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
