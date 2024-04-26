import Foundation
import Combine
import Services
import UIKit
import AnytypeCore

@MainActor
final class SpaceCreateViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private weak var output: SpaceCreateModuleOutput?
    
    // MARK: - State
    
    @Published var spaceName: String = ""
    let spaceGradient: GradientId = .random
    var spaceIcon: Icon { .object(.space(.gradient(spaceGradient))) }
    @Published var spaceType: SpaceAccessType = .private
    @Published var createLoadingState: Bool = false
    @Published var dismiss: Bool = false
    
    init(
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        workspaceService: WorkspaceServiceProtocol,
        output: SpaceCreateModuleOutput?
    ) {
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.workspaceService = workspaceService
        self.output = output
    }
    
    func onTapCreate() {
        guard !createLoadingState else { return }
        Task {
            createLoadingState = true
            defer {
                createLoadingState = false
            }
            let spaceId = try await workspaceService.createSpace(name: spaceName, gradient: spaceGradient, accessibility: spaceType, useCase: .empty)
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
