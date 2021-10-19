import Foundation
import Combine
import BlocksModels


final class ObjectActionsViewModel: ObservableObject {
    private let service: OtherObjectActionsService

    @Published var details: ObjectDetails = ObjectDetails(id: "", rawDetails: []) {
        didSet {
            objectActions = ObjectAction.allCasesWith(details: details)
        }
    }
    @Published var objectActions: [ObjectAction] = []

    init(objectId: String) {
        self.service = OtherObjectActionsService(objectId: objectId)
    }

    func changeArchiveState() {
        service.setArchive(!details.isArchived)
    }

    func changeFavoriteSate() {
        service.setFavorite(!details.isFavorite)
    }

    func moveTo() {
    }

    func template() {
    }

    func search() {
    }

}
