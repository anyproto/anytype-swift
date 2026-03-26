import SwiftUI
import Factory
import AnytypeCore

@Observable
final class SpaceCreateCoordinatorViewModel: SpaceCreateModuleOutput {

    @ObservationIgnored
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol

    let data: SpaceCreateData

    var localObjectIconPickerData: LocalObjectIconPickerData?

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

    func onSpaceCreated(spaceId: String) async throws {
        try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
    }
}
