import SwiftUI
import Factory

struct HomePagePickerData: Identifiable, Equatable {
    let spaceId: String
    var id: String { spaceId }
}

@MainActor
final class SpaceCreateCoordinatorViewModel: ObservableObject, SpaceCreateModuleOutput {

    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol

    let data: SpaceCreateData

    @Published var localObjectIconPickerData: LocalObjectIconPickerData?
    @Published var homePagePickerData: HomePagePickerData?

    private var pendingSpaceId: String?

    init(data: SpaceCreateData) {
        self.data = data
    }

    func onHomePagePickerFinished() {
        guard let spaceId = pendingSpaceId else { return }
        pendingSpaceId = nil
        Task {
            try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
        }
    }

    // MARK: - SpaceCreateModuleOutput

    func onIconPickerSelected(fileData: FileData?, output: any LocalObjectIconPickerOutput) {
        localObjectIconPickerData = LocalObjectIconPickerData(
            fileData: fileData,
            output: output
        )
    }

    func onSpaceCreated(spaceId: String) {
        pendingSpaceId = spaceId
        homePagePickerData = HomePagePickerData(spaceId: spaceId)
    }
}
