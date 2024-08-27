import Foundation
import Combine
import Services
import UIKit
import AnytypeCore

@MainActor
final class SpaceCreateViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let sceneId: String
    
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    private weak var output: (any SpaceCreateModuleOutput)?
    
    // MARK: - State
    
    @Published var spaceName: String = ""
    let spaceGradient: GradientId = .random
    var spaceIcon: Icon { .object(.space(.gradient(spaceGradient))) }
    @Published var spaceAccessType: SpaceAccessType = .private
    @Published var createLoadingState: Bool = false
    @Published var dismiss: Bool = false
    
    init(sceneId: String, output: (any SpaceCreateModuleOutput)?) {
        self.sceneId = sceneId
        
        self.output = output
    }
    
    func onTapCreate() {
        guard !createLoadingState else { return }
        Task {
            createLoadingState = true
            defer {
                createLoadingState = false
            }
            let spaceId = try await workspaceService.createSpace(name: spaceName, gradient: spaceGradient, accessType: spaceAccessType, useCase: .empty)
            try await spaceSetupManager.setActiveSpace(sceneId: sceneId, spaceId: spaceId)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AnytypeAnalytics.instance().logCreateSpace(route: .navigation)
            output?.spaceCreateWillDismiss()
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
