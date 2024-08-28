import SwiftUI
import DeepLinks
import Services
import Combine


@MainActor
final class SpaceHubCoordinatorViewModel: ObservableObject {
    @Published var showSpace = false
    @Published var showSpaceManager = false
    @Published var showSpaceShareTip = false
    @Published var sharingSpaceId: StringIdentifiable?
    @Published var spaceInfo: AccountInfo?
    @Published var showSpaceSwitchData: SpaceSwitchModuleData?
    @Published var membershipTierId: IntIdentifiable?
    @Published var showGalleryImport: GalleryInstallationData?
    @Published var spaceJoinData: SpaceJoinModuleData?
    @Published var membershipNameFinalizationData: MembershipTier?
    
    var keyboardDismiss: (() -> ())?
    var dismissAllPresented: DismissAllPresented?
    
    let sceneId = UUID().uuidString
    
    @Injected(\.appActionStorage)
    private var appActionsStorage: AppActionStorage
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    
    private var membershipStatusSubscription: AnyCancellable?
    
    init() {
        startSubscriptions()
    }
    
    func onManageSpacesSelected() {
        showSpaceManager = true
    }
    
    // MARK: - Setup
    func setup() async {
        await spaceSetupManager.registerSpaceSetter(sceneId: sceneId, setter: activeSpaceManager)
    }
    
    func startHandleAppActions() async {
        for await action in appActionsStorage.$action.values {
            if let action {
                try? await handleAppAction(action: action)
                appActionsStorage.action = nil
            }
        }
    }
    
    func startHandleWorkspaceInfo() async {
        await activeSpaceManager.setupActiveSpace()
        for await info in activeSpaceManager.workspaceInfoPublisher.values {
            switchSpace(info: info)
        }
    }

    // MARK: - Private
    
    private func startSubscriptions() {
        membershipStatusSubscription = Container.shared
            .membershipStatusStorage.resolve()
            .statusPublisher.receiveOnMain()
            .sink { [weak self] membership in
                guard membership.status == .pendingRequiresFinalization else { return }
                
                self?.membershipNameFinalizationData = membership.tier
            }
    }

    // MARK: - Private
    private func switchSpace(info newInfo: AccountInfo) {
        Task {
            // TEMP: create version of active space manager with nullable accounts
            guard newInfo != .empty else { return }
            
            
            showSpace = false
            Task {
                try await Task.sleep(seconds:0.1)
                spaceInfo = newInfo
                showSpace = true
            }
            
            // TODO: Store paths
            
        }
    }
    
    private func handleAppAction(action: AppAction) async throws {
        keyboardDismiss?()
        await dismissAllPresented?()
        switch action {
        case .createObjectFromQuickAction(let typeId):
            createAndShowNewObject(typeId: typeId, route: .homeScreen)
        case .deepLink(let deepLink):
            try await handleDeepLink(deepLink: deepLink)
        }
    }
    
    private func createAndShowNewObject(
            typeId: String,
            route: AnalyticsEventsRouteKind
        ) {
            // TODO: Product decision
        }
        
    private func handleDeepLink(deepLink: DeepLink) async throws {
        switch deepLink {
        case .createObjectFromWidget:
            // TODO: Product decision
            break
        case .showSharingExtension:
            // TODO: Product decision
            // sharingSpaceId = ???
            break
        case .spaceSelection:
            showSpaceSwitchData = SpaceSwitchModuleData(activeSpaceId: spaceInfo?.accountSpaceId, sceneId: sceneId)
        case let .galleryImport(type, source):
            showGalleryImport = GalleryInstallationData(type: type, source: source)
        case .invite(let cid, let key):
            spaceJoinData = SpaceJoinModuleData(cid: cid, key: key, sceneId: sceneId)
        case .object(let objectId, let spaceId):
            // TODO: Open space and show object
            break
//                let document = documentsProvider.document(objectId: objectId, mode: .preview)
//                try await document.open()
//                guard let editorData = document.details?.editorScreenData() else { return }
//                try await push(data: editorData)
        case .spaceShareTip:
            showSpaceShareTip = true
        case .membership(let tierId):
            guard accountManager.account.isInProdNetwork else { return }
            membershipTierId = tierId.identifiable
        }
    }

}
