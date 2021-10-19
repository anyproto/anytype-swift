import Foundation
import Combine
import BlocksModels


final class ObjectActionsViewModel: ObservableObject {
    private let service = ObjectActionsService()
    private let objectId: BlockId

    @Published var details: ObjectDetails = ObjectDetails(id: "", rawDetails: []) {
        didSet {
            objectActions = ObjectAction.allCasesWith(details: details)
        }
    }
    @Published var objectActions: [ObjectAction] = []

    init(objectId: String) {
        self.objectId = objectId
    }

    func changeArchiveState() {
        service.setArchive(objectId: objectId, !details.isArchived)
    }

    func changeFavoriteSate() {
        service.setFavorite(objectId: objectId, !details.isFavorite)
    }

    func moveTo() {
    }

    func template() {
    }

    func search() {
    }

}
