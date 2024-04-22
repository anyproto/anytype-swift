import UIKit
import Services
import AnytypeCore

final class SpaceViewIconActionHandler: ObjectIconActionHandlerProtocol {
    
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.fileActionsService)
    private var fileService: FileActionsServiceProtocol
    
    func handleIconAction(document: BaseDocumentGeneralProtocol, action: ObjectIconPickerAction) {
        guard let spaceId = document.details?.targetSpaceId else {
            anytypeAssertionFailure("Target space id is empty")
            return
        }
        switch action {
        case .setIcon(let iconSource):
            switch iconSource {
            case .emoji:
                anytypeAssertionFailure("Try to setup emoji for space")
                break
            case .upload(let itemProvider):
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setIcon)
                let safeSendableItemProvider = SafeSendable(value: itemProvider)
                Task {
                    let data = try await fileService.createFileData(source: .itemProvider(safeSendableItemProvider.value))
                    let fileDetails = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
                    try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId(fileDetails.id)])
                }
            }
        case .removeIcon:
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeIcon)
            Task {
                try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId("")])
            }
        }
    }
}
