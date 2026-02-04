import ProtobufMessages

public protocol DataviewDefaultViewCorrectorServiceProtocol: AnyObject, Sendable {
    /// Corrects the default view type from Grid (table) to List for newly created Sets/Collections.
    /// Grid layout is deprecated on mobile, so we convert any table views to list views.
    func correctDefaultViewTypeIfNeeded(objectId: String, spaceId: String) async throws
}

final class DataviewDefaultViewCorrectorService: DataviewDefaultViewCorrectorServiceProtocol {

    func correctDefaultViewTypeIfNeeded(objectId: String, spaceId: String) async throws {
        let objectShow = try await ClientCommands.objectShow(.with {
            $0.contextID = objectId
            $0.objectID = objectId
            $0.spaceID = spaceId
        }).invoke()

        for block in objectShow.objectView.blocks {
            guard case .dataview(let dataview) = block.content else { continue }

            for view in dataview.views where view.type == .table {
                var updatedView = view
                updatedView.type = .list

                try await ClientCommands.blockDataviewViewUpdate(.with {
                    $0.contextID = objectId
                    $0.blockID = block.id
                    $0.viewID = view.id
                    $0.view = updatedView
                }).invoke()
                return
            }
        }
    }
}
