import SwiftUI
import DeepLinks
import Services


@MainActor
final class SpaceHubCoordinatorViewModel: ObservableObject {
    @Published var showHome = false
    @Published var showSharing = false
    @Published var showSpaceManager = false
    @Published var showSpaceShareTip = false
    @Published var spaceInfo: AccountInfo?
    @Published var showSpaceSwitchData: SpaceSwitchModuleData?
    @Published var membershipTierId: IntIdentifiable?
    @Published var showGalleryImport: GalleryInstallationData?
    @Published var spaceJoinData: SpaceJoinModuleData?
    
    var keyboardDismiss: (() -> ())?
    var dismissAllPresented: DismissAllPresented?
    
    let homeSceneId = UUID().uuidString
    
    @Injected(\.appActionStorage)
    private var appActionsStorage: AppActionStorage
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    
    @Injected(\.homeActiveSpaceManager)
    private var homeActiveSpaceManager: any HomeActiveSpaceManagerProtocol
    
    init() {
        Task {
            await spaceSetupManager.registryHome(homeSceneId: homeSceneId, manager: homeActiveSpaceManager)
        }
    }
    
    
    func startDeepLinkTask() async {
        for await action in appActionsStorage.$action.values {
            if let action {
                try? await handleAppAction(action: action)
                appActionsStorage.action = nil
            }
        }
    }
    
    func startHandleWorkspaceInfo() async {
        await homeActiveSpaceManager.setupActiveSpace()
        for await info in homeActiveSpaceManager.workspaceInfoPublisher.values {
            switchSpace(info: info)
        }
    }
    
    func onManageSpacesSelected() {
        showSpaceManager = true
    }

    // MARK: - Private
    private func switchSpace(info newInfo: AccountInfo) {
        Task {
            // TEMP: create version of active space manager with nullable accounts
            guard newInfo != .empty else { return }
            
            
            showHome = false
            Task {
                try await Task.sleep(seconds:0.1)
                spaceInfo = newInfo
                showHome = true
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
                // TODO: Support sharing when no space is selected
                break
//                showSharing = true
            case .spaceSelection:
                // TODO: Support spaceSwitchModule without active space
                break
//                guard let info else {
//                    anytypeAssertionFailure("Try open without info")
//                    return
//                }
//                showSpaceSwitchData = SpaceSwitchModuleData(activeSpaceId: info.accountSpaceId, homeSceneId: homeSceneId)
            case let .galleryImport(type, source):
                showGalleryImport = GalleryInstallationData(type: type, source: source)
            case .invite(let cid, let key):
                spaceJoinData = SpaceJoinModuleData(cid: cid, key: key, homeSceneId: homeSceneId)
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
