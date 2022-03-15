import Foundation
import Combine
import BlocksModels


final class ObjectActionsViewModel: ObservableObject {
    private let service = ObjectActionsService()
    private let objectId: BlockId

    var details: ObjectDetails = ObjectDetails(id: "", values: [:]) {
        didSet {
            objectActions = ObjectAction.allCasesWith(
                details: details,
                objectRestrictions: objectRestrictions,
                isLocked: isLocked
            )
        }
    }
    var objectRestrictions: ObjectRestrictions = ObjectRestrictions() {
        didSet {
            objectActions = ObjectAction.allCasesWith(
                details: details,
                objectRestrictions: objectRestrictions,
                isLocked: isLocked
            )
        }
    }
    var isLocked: Bool = false {
        didSet {
            objectActions = ObjectAction.allCasesWith(
                details: details,
                objectRestrictions: objectRestrictions,
                isLocked: isLocked
            )
        }
    }
    @Published var objectActions: [ObjectAction] = []

    let popScreenAction: () -> ()
    var dismissSheet: () -> () = {}
    
    init(objectId: String, popScreenAction: @escaping () -> ()) {
        self.objectId = objectId
        self.popScreenAction = popScreenAction
    }

    func changeArchiveState() {
        let isArchived = !details.isArchived
        service.setArchive(objectId: objectId, isArchived)
        if isArchived {
            popScreenAction()
            dismissSheet()
        }
    }

    func changeFavoriteSate() {
        service.setFavorite(objectId: objectId, !details.isFavorite)
    }

    func changeLockState() {
        service.setLocked(!isLocked, objectId: objectId)
    }

    func moveTo() {
    }

    func template() {
    }

    func search() {
    }

}
