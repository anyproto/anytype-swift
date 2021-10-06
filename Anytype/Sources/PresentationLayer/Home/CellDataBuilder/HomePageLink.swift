import BlocksModels

struct HomePageLink {
    let blockId: BlockId
    let targetBlockId: BlockId // Id of linked page
    let details: DetailsDataProtocol?
    
    var isLoading: Bool {
        guard let details = details else {
            return true
        }
 
        return details.rawDetails.isEmpty
    }
    
    var isArchived: Bool {
        details?.isArchived ?? false
    }
}
