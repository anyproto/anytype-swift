import Foundation
import Combine
import BlocksModels
import AnytypeCore

final class ObjectActionsViewModel: ObservableObject {
    
    private let objectId: AnytypeId
    private let service = ServiceLocator.shared.objectActionsService()
    
    @Published var details: ObjectDetails = ObjectDetails(id: "".asAnytypeId!, values: [:]) {
        didSet {
            objectActions = ObjectAction.allCasesWith(
                details: details,
                objectRestrictions: objectRestrictions,
                isLocked: isLocked
            )
        }
    }
    @Published var objectRestrictions: ObjectRestrictions = ObjectRestrictions() {
        didSet {
            objectActions = ObjectAction.allCasesWith(
                details: details,
                objectRestrictions: objectRestrictions,
                isLocked: isLocked
            )
        }
    }
    @Published var isLocked: Bool = false {
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
    
    init(objectId: AnytypeId, popScreenAction: @escaping () -> ()) {
        self.objectId = objectId
        self.popScreenAction = popScreenAction
    }

    func changeArchiveState() {
        let isArchived = !details.isArchived
        service.setArchive(objectId: objectId.value, isArchived)
        if isArchived {
            popScreenAction()
            dismissSheet()
        }
    }

    func changeFavoriteSate() {
        service.setFavorite(objectId: objectId.value, !details.isFavorite)
    }

    func changeLockState() {
        service.setLocked(!isLocked, objectId: objectId.value)
    }

    func moveTo() {
    }

    func template() {
    }

    func search() {
    }

}
