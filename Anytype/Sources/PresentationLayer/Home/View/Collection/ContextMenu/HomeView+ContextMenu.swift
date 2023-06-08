import Foundation

extension HomeViewModel {
    
    func addToFavorite(data: HomeCellData) {
        objectActionsService.setFavorite(objectIds: [data.destinationId], true)
    }
    
    func removeFromFavorite(data: HomeCellData) {
        objectActionsService.setFavorite(objectIds: [data.destinationId], false)
    }
    
    func moveToBin(data: HomeCellData) {
        objectActionsService.setArchive(objectIds: [data.destinationId], true)
    }
}
