import Foundation
import Combine
import Services
import UIKit
import AnytypeCore

@MainActor
final class SpaceCreateViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    private weak var output: SpaceCreateModuleOutput?
    
    // MARK: - State
    
    @Published var spaceName: String = ""
    let spaceGradient: GradientId = .random
    var spaceIcon: Icon { .object(.space(.gradient(spaceGradient))) }
    @Published var spaceAccessType: SpaceAccessType = .personal
    @Published var createLoadingState: Bool = false
    @Published var dismiss: Bool = false
    
    init(output: SpaceCreateModuleOutput?) {
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
            try await activeWorkspaceStorage.setActiveSpace(spaceId: spaceId)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            AnytypeAnalytics.instance().logCreateSpace()
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
