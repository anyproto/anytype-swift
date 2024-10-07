import Foundation
import Combine
import Services
import UIKit

struct SpaceSwitchModuleData: Hashable, Identifiable {
    let activeSpaceId: String?
    let sceneId: String
    
    var id: Int { hashValue }
}

@MainActor
final class SpaceSwitchViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let data: SpaceSwitchModuleData
    
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    private weak var output: (any SpaceSwitchModuleOutput)?
    
    // MARK: - State
    
    private var spaces: [ParticipantSpaceViewData]?
    private var subscriptions = [AnyCancellable]()
    
    @Published var rows = [SpaceRowModel]()
    @Published var dismiss: Bool = false
    @Published var scrollToRowId: String? = nil
    @Published var spaceViewForDelete: SpaceView?
    @Published var spaceViewForLeave: SpaceView?
    @Published var spaceViewStopSharing: SpaceView?
    
    init(data: SpaceSwitchModuleData, output: (any SpaceSwitchModuleOutput)?) {
        self.data = data
        self.output = output
        startSpacesSubscriptions()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenVault(type: "Menu")
    }
    
    func onAddSpaceTap() {
        output?.onCreateSpaceSelected()
    }
    
    // MARK: - Private
    
    private func startSpacesSubscriptions() {
        
        participantSpacesStorage.activeParticipantSpacesPublisher
            .receiveOnMain()
            .sink { [weak self] workspaces in
                self?.spaces = workspaces
                self?.updateViewModel()
            }
            .store(in: &subscriptions)
    }
    
    private func stopSpacesSubscriptions() {
        subscriptions.removeAll()
    }
    
    private func updateViewModel() {
        guard let spaces else {
            rows = []
            return
        }
        let isSelected: (String) -> (Bool) = { [weak self] in
            guard let activeSpaceId = self?.data.activeSpaceId else { return false}
            return activeSpaceId == $0
        }
        
        rows = spaces.map { participantSpaceView -> SpaceRowModel in
            let spaceView = participantSpaceView.spaceView
            return SpaceRowModel(
                id: spaceView.id,
                title: spaceView.title,
                icon: spaceView.objectIconImage,
                isSelected: isSelected(spaceView.targetSpaceId),
                shared: spaceView.isShared,
                onTap: { [weak self] in
                    self?.onTapWorkspace(workspace: spaceView)
                },
                onDelete: participantSpaceView.canBeDelete ? { [weak self] in
                    AnytypeAnalytics.instance().logClickDeleteSpace(route: .navigation)
                    self?.spaceViewForDelete = spaceView
                } : nil,
                onLeave: participantSpaceView.canLeave ? { [weak self] in
                    self?.spaceViewForLeave = spaceView
                } : nil,
                onStopShare: participantSpaceView.canStopSharing ? { [weak self] in
                    self?.spaceViewStopSharing = spaceView
                } : nil
            )
        }
        
        if scrollToRowId.isNil, let selectedRow = rows.first(where: { $0.isSelected }) {
            scrollToRowId = selectedRow.id
        }
    }
    
    private func onTapWorkspace(workspace: SpaceView) {
        Task {
            stopSpacesSubscriptions()
            try await spaceSetupManager.setActiveSpace(sceneId: data.sceneId, spaceId: workspace.targetSpaceId)
            UISelectionFeedbackGenerator().selectionChanged()
            dismiss.toggle()
        }
    }
}
