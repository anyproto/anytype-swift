import BlocksModels

struct HomePageLink {
    let blockId: BlockId
    let targetBlockId: BlockId // Id of linked page
    let details: ObjectDetails?
    
    var isLoading: Bool {
        return details.isNil
//        guard let details = details else {
//            return true
//        }
 
        // TODO: - fix details
//        return false
//        return details.rawDetails.isEmpty
    }
    
    var isArchived: Bool {
        details?.isArchived ?? false
    }
}
