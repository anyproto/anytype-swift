import Foundation
import Combine
import BlocksModels


final class ObjectActionsViewModel: ObservableObject {
    private let archiveService: OtherObjectActionsService

    @Published var details: DetailsDataProtocol = DetailsData.empty {
        didSet {
            objectActions = details.rawDetails.isEmpty ? [] : ObjectAction.allCasesWith(details: details)
        }
    }
    @Published var objectActions: [ObjectAction] = []

    init(objectId: String) {
        self.archiveService = OtherObjectActionsService(objectId: objectId)
    }

    func changeArchiveState() {
        let isArchived = details.isArchived ?? false
        archiveService.setArchive(!isArchived)
    }

    func changeFavoriteSate() {
        let isFavorite = details.isFavorite ?? false
        archiveService.setFavorite(!isFavorite)
    }

    func moveTo() {
    }

    func template() {
    }

    func search() {
    }

}
