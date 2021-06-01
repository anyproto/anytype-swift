import BlocksModels

struct HomePageLink {
    let blockId: BlockId
    let targetBlockId: BlockId // Id of linked page
    let details: DetailsProviderProtocol?
    
    var isLoading: Bool {
        details.isNil
    }
}
