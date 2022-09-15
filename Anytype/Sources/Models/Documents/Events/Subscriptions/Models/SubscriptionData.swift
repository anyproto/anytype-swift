import Foundation
import BlocksModels

enum SubscriptionData {
    
    case search(SubscriptionDescriptionSearch)
    case objects(SubscriptionDescriptionObjects)
    
    var identifier: SubscriptionId {
        switch self {
        case .search(let description):
            return description.identifier
        case .objects(let description):
            return description.identifier
        }
    }
}

struct SubscriptionDescriptionSearch {
    let identifier: SubscriptionId
    let sorts: [DataviewSort]
    let filters: [DataviewFilter]
    let limit: Int
    let offset: Int
    let keys: [String]
    let afterID: String?
    let beforeID: String?
    let source: [String]
    let ignoreWorkspace: String?
    let noDepSubscription: Bool
    
    init(
        identifier: SubscriptionId,
        sorts: [DataviewSort],
        filters: [DataviewFilter],
        limit: Int,
        offset: Int,
        keys: [String],
        afterID: String? = nil,
        beforeID: String? = nil,
        source: [String] = [],
        ignoreWorkspace: String? = nil,
        noDepSubscription: Bool = false
    ) {
        self.identifier = identifier
        self.sorts = sorts
        self.filters = filters
        self.limit = limit
        self.offset = offset
        self.keys = keys
        self.afterID = afterID
        self.beforeID = beforeID
        self.source = source
        self.ignoreWorkspace = ignoreWorkspace
        self.noDepSubscription = noDepSubscription
    }
}

struct SubscriptionDescriptionObjects {
    
    let identifier: SubscriptionId
    let objectIds: [String]
    let keys: [String]
    let ignoreWorkspace: String?
    
    init(
        identifier: SubscriptionId,
        objectIds: [String],
        keys: [String],
        ignoreWorkspace: String? = nil
    ) {
        self.identifier = identifier
        self.objectIds = objectIds
        self.keys = keys
        self.ignoreWorkspace = ignoreWorkspace
    }
}


extension SubscriptionData {
    
    static func set(_ data: SetSubsriptionData) -> Self {
        
        let numberOfRowsPerPageInSubscriptions = UserDefaultsConfig.rowsPerPageInSet
        
        let keys = data.buildKeys(
            with: homeDetailsKeys
        )
        
        let offset = (data.currentPage - 1) * numberOfRowsPerPageInSubscriptions
        
        return .search(SubscriptionDescriptionSearch(
            identifier: SubscriptionId.set,
            sorts: data.sorts,
            filters: data.filters,
            limit: numberOfRowsPerPageInSubscriptions,
            offset: offset,
            keys: keys,
            source: data.source
        ))
    }
    
    
    
    private static var homeDetailsKeys: [String] {
        let keys: [BundledRelationKey] = [
        .id, .iconEmoji, .iconImage, .name, .snippet, .description, .type, .layout, .isArchived, .isDeleted, .done, .isFavorite
        ]
        return keys.map { $0.rawValue }
    }
    
    private static func buildFilters(isArchived: Bool, typeUrls: [String]) -> [DataviewFilter] {
        [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: isArchived),
            SearchHelper.typeFilter(typeUrls: typeUrls)
        ]
    }
}


struct SetSubsriptionData: Hashable {
    let source: [String]
    let sorts: [DataviewSort]
    let filters: [DataviewFilter]
    let options: [DataviewRelationOption]
    let currentPage: Int
    let coverRelationKey: String
    
    init(dataView: BlockDataview, view: DataviewView, currentPage: Int) {
        self.source = dataView.source
        self.sorts = view.sorts
        self.filters = view.filters
        self.options = view.options
        self.currentPage = currentPage
        self.coverRelationKey = view.coverRelationKey
    }
    
    func buildKeys(with additionalKeys: [String]) -> [String] {
        var keys = additionalKeys
        keys.append(contentsOf: options.map { $0.key })
        keys.append(coverRelationKey)
        keys.append(contentsOf: [
            BundledRelationKey.coverId.rawValue,
            BundledRelationKey.coverScale.rawValue,
            BundledRelationKey.coverType.rawValue,
            BundledRelationKey.coverX.rawValue,
            BundledRelationKey.coverY.rawValue
        ])
        return keys
    }
}
