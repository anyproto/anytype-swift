import Foundation
import Combine
import BlocksModels
import AnytypeCore

final class ObjectActionsViewModel: ObservableObject {
    
    var objectActions: [ObjectAction] {
        guard let details = details else { return [] }

        return ObjectAction.allCasesWith(
            details: details,
            objectRestrictions: objectRestrictions,
            isLocked: isLocked
        )
    }
    
    @Published var details: ObjectDetails?
    @Published var objectRestrictions: ObjectRestrictions = ObjectRestrictions()
    @Published var isLocked: Bool = false

    let popScreenAction: () -> ()
    var dismissSheet: () -> () = {}
    
    private let objectId: AnytypeId
    private let service = ServiceLocator.shared.objectActionsService()
    
    init(objectId: AnytypeId, popScreenAction: @escaping () -> ()) {
        self.objectId = objectId
        self.popScreenAction = popScreenAction
    }

    func changeArchiveState() {
        guard let details = details else { return }
        
        let isArchived = !details.isArchived
        service.setArchive(objectId: objectId.value, isArchived)
        if isArchived {
            popScreenAction()
            dismissSheet()
        }
    }

    func changeFavoriteSate() {
        guard let details = details else { return }

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
