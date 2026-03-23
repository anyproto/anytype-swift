import SwiftUI
import Factory
import AnytypeCore


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
    var newHomepagePickerData: HomePagePickerData?

    @ObservationIgnored
    private var pendingSpaceId: String?
    
    init(data: SpaceCreateData) {
        self.data = data
    }

    func onHomePagePickerFinished() async throws {
        guard let spaceId = pendingSpaceId else { return }
        pendingSpaceId = nil
        try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
    }

    // MARK: - SpaceCreateModuleOutput

    func onIconPickerSelected(fileData: FileData?, output: any LocalObjectIconPickerOutput) {
        localObjectIconPickerData = LocalObjectIconPickerData(
            fileData: fileData,
            output: output
        )
    }

    func onHomepagePickerFinished(result: HomepagePickerResult) async throws {
        guard let spaceId = pendingSpaceId else { return }
        pendingSpaceId = nil

        switch result {
        case .homepageSet:
            try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
            // TODO: Navigate to the homepage object (separate task)
        case .later:
            try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
            // TODO: Handle temporary widgets (separate task)
        }
    }

    func onSpaceCreated(spaceId: String) async throws {
        if FeatureFlags.homePage {
            pendingSpaceId = spaceId
            newHomepagePickerData = HomePagePickerData(spaceId: spaceId)
        } else {
            try await activeSpaceManager.setActiveSpace(spaceId: spaceId)
        }
    }
}
