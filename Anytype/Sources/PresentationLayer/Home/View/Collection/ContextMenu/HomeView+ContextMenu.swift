import Foundation

extension HomeViewModel {
    
    func addToFavorite(data: HomeCellData) {
        objectActionsService.setFavorite(objectId: data.destinationId.value, true)
    }
    
    func removeFromFavorite(data: HomeCellData) {
        objectActionsService.setFavorite(objectId: data.destinationId.value, false)
    }
    
    func moveToBin(data: HomeCellData) {
        objectActionsService.setArchive(objectId: data.destinationId.value, true)
    }
}
