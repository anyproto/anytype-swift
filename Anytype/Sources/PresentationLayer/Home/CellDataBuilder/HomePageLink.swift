import BlocksModels

struct HomePageLink {
    let blockId: BlockId
    let targetBlockId: BlockId // Id of linked page
    let details: DetailsDataProtocol?
    
    var isLoading: Bool {
        details.isNil
    }
    
    var isArchived: Bool {
        details?.isArchived ?? false
    }
}
