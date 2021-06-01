import BlocksModels

struct HomePageLink {
    let blockId: BlockId
    let targetBlockId: BlockId // Id of linked page
    let details: DetailsProviderProtocol?
    let type: BlockLink.Style
    
    var isLoading: Bool {
        details.isNil
    }
}
