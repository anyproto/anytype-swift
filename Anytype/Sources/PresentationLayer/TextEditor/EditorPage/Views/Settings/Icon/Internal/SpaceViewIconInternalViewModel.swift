import UIKit
import Services
import AnytypeCore

final class SpaceViewIconInternalViewModel {
    private let workspaceService: WorkspaceServiceProtocol
    private let fileService: FileActionsServiceProtocol
    
    init(
        workspaceService: WorkspaceServiceProtocol,
        fileService: FileActionsServiceProtocol
    ) {
        self.workspaceService = workspaceService
        self.fileService = fileService
    }
        
    func handleIconAction(spaceId: String, action: ObjectIconPickerAction) {
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
