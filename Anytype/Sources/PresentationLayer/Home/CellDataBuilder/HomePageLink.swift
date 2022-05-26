import BlocksModels
import AnytypeCore

struct HomePageLink {
    let blockId: AnytypeId
    let targetBlockId: AnytypeId // Id of linked page
    let details: ObjectDetails?
    
    var isLoading: Bool {
        details.isNil
    }
    
    var isArchived: Bool {
        details?.isArchived ?? false
    }
    
    var isDeleted: Bool {
        details?.isDeleted ?? false
    }
    
    var isFavorite: Bool {
        details?.isFavorite ?? false
    }
}
