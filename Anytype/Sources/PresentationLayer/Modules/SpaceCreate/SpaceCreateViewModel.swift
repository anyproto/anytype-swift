import Foundation
import Combine
import Services
import UIKit
import AnytypeCore

@MainActor
final class SpaceCreateViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let data: SpaceCreateData
    
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    // MARK: - State
    
    @Published var spaceName: String = ""
    let spaceIconOption = IconColorStorage.randomOption()
    var spaceIcon: Icon { .object(.space(.name(name: spaceName, iconOption: spaceIconOption))) }
    @Published var spaceAccessType: SpaceAccessType = .private
    @Published var createLoadingState: Bool = false
    @Published var dismiss: Bool = false
    
    init(data: SpaceCreateData) {
        self.data = data
    }
    
    func onTapCreate() {
        guard !createLoadingState else { return }
        Task {
            createLoadingState = true
            defer {
                createLoadingState = false
            }
            let spaceId = try await workspaceService.createSpace(name: spaceName, iconOption: spaceIconOption, accessType: spaceAccessType, useCase: .empty, withChat: FeatureFlags.homeSpaceLevelChat)
            
            // Hack: remove after middleware fix
            // https://linear.app/anytype/issue/IOS-3588/new-space-auto-renames-to-onboarding-22-without-name
            try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [
                .name(spaceName),
                .iconOption(spaceIconOption)
            ])
            
            try await spaceSetupManager.setActiveSpace(sceneId: data.sceneId, spaceId: spaceId)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AnytypeAnalytics.instance().logCreateSpace(route: .navigation)
            dismissForLegacyOS()
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceCreate()
    }
    
    // MARK: - Private
    
    @available(iOS, deprecated: 17)
    private func dismissForLegacyOS() {
        if #available(iOS 17, *) {
        } else {
            dismiss.toggle()
        }
    }
}
