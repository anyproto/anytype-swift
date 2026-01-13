import SwiftUI
import Factory

struct HomePagePickerData: Identifiable, Equatable {
    let spaceId: String
    var id: String { spaceId }
}

@Observable
final class SpaceCreateCoordinatorViewModel: SpaceCreateModuleOutput {
  
    @ObservationIgnored
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol


    let data: SpaceCreateData

    var localObjectIconPickerData: LocalObjectIconPickerData?
    var homePagePickerData: HomePagePickerData?

    @ObservationIgnored
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
