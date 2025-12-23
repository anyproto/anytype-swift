import SwiftUI
import Services
import AnytypeCore

@MainActor
final class SpaceCreateCoordinatorViewModel: ObservableObject, SpaceCreateModuleOutput {

    let data: SpaceCreateData

    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol

    @Published var localObjectIconPickerData: LocalObjectIconPickerData?
    @Published var spaceStartWithData: SpaceStartWithData?
    @Published var dismiss = false

    init(data: SpaceCreateData) {
        self.data = data
    }

    // MARK: - SpaceCreateModuleOutput

    func onIconPickerSelected(fileData: FileData?, output: any LocalObjectIconPickerOutput) {
        localObjectIconPickerData = LocalObjectIconPickerData(
            fileData: fileData,
            output: output
        )
    }

    func onSpaceCreated(spaceId: String) {
        spaceStartWithData = SpaceStartWithData(spaceId: spaceId)
    }

    // MARK: - Start With Selection

    func onStartWithOptionSelected(_ option: SpaceStartWithOption, spaceId: String) {
        Task {
            do {
                switch option {
                case .page:
                    let details = try await objectActionsService.createObject(
                        name: "",
                        typeUniqueKey: .page,
                        shouldDeleteEmptyObject: true,
                        shouldSelectType: false,
                        shouldSelectTemplate: true,
                        spaceId: spaceId,
                        origin: .none,
                        templateId: nil
                    )
                    let editorData = EditorScreenData.page(EditorPageObject(objectId: details.id, spaceId: spaceId))
                    userDefaults.setLastOpenedScreen(spaceId: spaceId, screen: .editor(editorData))

                case .chat:
                    let details = try await objectActionsService.createObject(
                        name: "",
                        typeUniqueKey: .chatDerived,
                        shouldDeleteEmptyObject: false,
                        shouldSelectType: false,
                        shouldSelectTemplate: false,
                        spaceId: spaceId,
                        origin: .none,
                        templateId: nil
                    )
                    let chatData = ChatCoordinatorData(chatId: details.id, spaceId: spaceId)
                    userDefaults.setLastOpenedScreen(spaceId: spaceId, screen: .chat(chatData))

                case .widgets:
                    break
                }

                try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
                dismiss = true
            } catch {
                dismiss = true
            }
        }
    }
}
