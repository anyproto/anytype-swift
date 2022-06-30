import Foundation

extension HomeViewModel {
    
    func addToFavorite(data: HomeCellData) {
        objectActionsService.setFavorite(objectId: data.destinationId, true)
    }
    
    func removeFromFavorite(data: HomeCellData) {
        objectActionsService.setFavorite(objectId: data.destinationId, false)
    }
    
    func moveToBin(data: HomeCellData) {
        objectActionsService.setArchive(objectId: data.destinationId, true)
    }
}
