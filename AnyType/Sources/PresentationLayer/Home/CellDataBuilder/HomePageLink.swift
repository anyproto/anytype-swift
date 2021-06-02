import BlocksModels

struct HomePageLink {
    let blockId: BlockId
    let targetBlockId: BlockId // Id of linked page
    let details: DetailsData?
    let type: BlockLink.Style
    
    var isLoading: Bool {
        details.isNil
    }
}
