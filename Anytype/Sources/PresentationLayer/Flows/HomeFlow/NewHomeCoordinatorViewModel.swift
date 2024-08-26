import Foundation
import SwiftUI
import Combine
import Services
import AnytypeCore
import DeepLinks

@MainActor
final class NewHomeCoordinatorViewModel: ObservableObject,
                                             HomeWidgetsModuleOutput, CommonWidgetModuleOutput,
                                             HomeBottomNavigationPanelModuleOutput,
                                             SetObjectCreationCoordinatorOutput {
    
    // MARK: - DI
    
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.homeActiveSpaceManager)
    private var homeActiveSpaceManager: any HomeActiveSpaceManagerProtocol
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.pasteboardBlockService)
    private var pasteboardBlockService: any PasteboardBlockServiceProtocol
    @Injected(\.objectTypeProvider)
    private var typeProvider: any ObjectTypeProviderProtocol
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    @Injected(\.legacySetObjectCreationCoordinator)
    private var setObjectCreationCoordinator: any SetObjectCreationCoordinatorProtocol
    
    // MARK: - State
    
    private let homeSceneId = UUID().uuidString
    private var paths = [String: HomePath]()
    private var dismissAllPresented: DismissAllPresented?
    
    @Published var showChangeSourceData: WidgetChangeSourceSearchModuleModel?
    @Published var showChangeTypeData: WidgetTypeChangeData?
    @Published var showGlobalSearchData: GlobalSearchModuleData?
    @Published var showSpaceSwitchData: SpaceSwitchModuleData?
    @Published var showCreateWidgetData: CreateWidgetCoordinatorModel?
    @Published var showSpaceSettingsData: AccountInfo?
    @Published var showMembershipNameSheet: MembershipTier?

    
    @Published var editorPath = HomePath() {
        didSet { updateLastOpenedScreen() }
    }
    @Published var showTypeSearchForObjectCreation: Bool = false
    @Published var toastBarData = ToastBarData.empty
    @Published var pathChanging: Bool = false
    @Published var info: AccountInfo?
    
    @Binding var showHome: Bool
    
    private var currentSpaceId: String?
    
    var pageNavigation: PageNavigation {
        PageNavigation(
            push: { [weak self] data in
                self?.pushSync(data: data)
            }, pop: { [weak self] in
                self?.editorPath.pop()
            }, replace: { [weak self] data in
                self?.editorPath.replaceLast(data)
            }
        )
    }
    
    private var membershipStatusSubscription: AnyCancellable?

    init(showHome: Binding<Bool>) {
        _showHome = showHome
        
        Task {
            await spaceSetupManager.registryHome(homeSceneId: homeSceneId, manager: homeActiveSpaceManager)
        }
        
        membershipStatusSubscription = Container.shared
            .membershipStatusStorage.resolve()
            .statusPublisher.receiveOnMain()
            .sink { [weak self] membership in
                guard membership.status == .pendingRequiresFinalization else { return }
                
                self?.showMembershipNameSheet = membership.tier
            }
    }
    
    func startHandleWorkspaceInfo() async {
        await homeActiveSpaceManager.setupActiveSpace()
        for await info in homeActiveSpaceManager.workspaceInfoPublisher.values {
            switchSpace(info: info)
        }
    }
    
    func setDismissAllPresented(dismissAllPresented: DismissAllPresented) {
        self.dismissAllPresented = dismissAllPresented
    }
    
    func typeSearchForObjectCreationModule() -> TypeSearchForNewObjectCoordinatorView {        
        TypeSearchForNewObjectCoordinatorView(spaceId: homeActiveSpaceManager.workspaceInfo.accountSpaceId) { [weak self] details in
            guard let self else { return }
            openObject(screenData: details.editorScreenData())
        }
    }
    
    // MARK: - HomeWidgetsModuleOutput
    
    func onCreateWidgetSelected(context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: homeActiveSpaceManager.workspaceInfo.accountSpaceId,
            widgetObjectId: homeActiveSpaceManager.workspaceInfo.widgetsId,
            position: .end,
            context: context
        )
    }
    
    // MARK: - CommonWidgetModuleOutput
        
    func onObjectSelected(screenData: EditorScreenData) {
        openObject(screenData: screenData)
    }
    
    func onChangeSource(widgetId: String, context: AnalyticsWidgetContext) {
        showChangeSourceData = WidgetChangeSourceSearchModuleModel(
            widgetObjectId: homeActiveSpaceManager.workspaceInfo.widgetsId,
            spaceId: homeActiveSpaceManager.workspaceInfo.accountSpaceId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeSourceData = nil
            }
        )
    }

    func onChangeWidgetType(widgetId: String, context: AnalyticsWidgetContext) {
        showChangeTypeData = WidgetTypeChangeData(
            widgetObjectId: homeActiveSpaceManager.workspaceInfo.widgetsId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeTypeData = nil
            }
        )
    }
    
    func onAddBelowWidget(widgetId: String, context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: homeActiveSpaceManager.workspaceInfo.accountSpaceId,
            widgetObjectId: homeActiveSpaceManager.workspaceInfo.widgetsId,
            position: .below(widgetId: widgetId),
            context: context
        )
    }
    
    func onSpaceSelected() {
        showSpaceSettingsData = homeActiveSpaceManager.workspaceInfo
    }
    
    func onCreateObjectInSetDocument(setDocument: some SetDocumentProtocol) {
        setObjectCreationCoordinator.startCreateObject(setDocument: setDocument, output: self, customAnalyticsRoute: .widget)
    }
    
    // MARK: - HomeBottomNavigationPanelModuleOutput
    
    func onSearchSelected() {  
        showGlobalSearchData = GlobalSearchModuleData(
            spaceId: homeActiveSpaceManager.workspaceInfo.accountSpaceId,
            onSelect: { [weak self] screenData in
                self?.openObject(screenData: screenData)
            }
        )
    }
    
    func onCreateObjectSelected(screenData: EditorScreenData) {
        UISelectionFeedbackGenerator().selectionChanged()
        openObject(screenData: screenData)
    }

    func onProfileSelected() {
        guard let info else {
            anytypeAssertionFailure("Try open without info")
            return
        }
        showSpaceSwitchData = SpaceSwitchModuleData(activeSpaceId: info.accountSpaceId, homeSceneId: homeSceneId)
    }

    func onHomeSelected() {
        guard !pathChanging else { return }
        editorPath.popToRoot()
    }

    func onForwardSelected() {
        guard !pathChanging else { return }
        editorPath.pushFromHistory()
    }

    func onBackwardSelected() {
        guard !pathChanging else { return }
        editorPath.pop()
    }
    
    func onPickTypeForNewObjectSelected() {
        UISelectionFeedbackGenerator().selectionChanged()
        showTypeSearchForObjectCreation.toggle()
    }
    
    func onSpaceHubSelected() {
        UISelectionFeedbackGenerator().selectionChanged()
        showHome = false
    }

    // MARK: - SetObjectCreationCoordinatorOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pushSync(data: data)
    }
    
    // MARK: - Private
    
    private func updateLastOpenedScreen() {
        guard let currentSpaceId else { return }
        
        if let screen = editorPath.lastPathElement as? EditorScreenData {
            userDefaults.saveLastOpenedScreen(spaceId: currentSpaceId, screen: screen)
        } else if editorPath.lastPathElement is HomePath || editorPath.lastPathElement is AccountInfo  {
            userDefaults.saveLastOpenedScreen(spaceId: currentSpaceId, screen: nil)
        }
    }
    
    private func openObject(screenData: EditorScreenData) {
        pushSync(data: screenData)
    }
        
    private func pushSync(data: EditorScreenData) {
        Task { try await push(data: data) }
    }
        
    private func push(data: EditorScreenData) async throws {
        guard let objectId = data.objectId else {
            editorPath.push(data)
            return
        }
        let document = documentsProvider.document(objectId: objectId, mode: .preview)
        try await document.open()
        guard let details = document.details else {
            return
        }
        guard details.isSupportedForEdit else {
            toastBarData = ToastBarData(text: Loc.openTypeError(details.objectType.name), showSnackBar: true, messageType: .none)
            return
        }
        let spaceId = document.spaceId
        if currentSpaceId != spaceId {
            // Check space Is deleted
            guard workspacesStorage.spaceView(spaceId: spaceId).isNotNil else { return }
            
            if let currentSpaceId = currentSpaceId {
                paths[currentSpaceId] = editorPath
            }
           
            currentSpaceId = spaceId
            try await homeActiveSpaceManager.setActiveSpace(spaceId: spaceId)
            
            var path = paths[spaceId] ?? HomePath()
            if path.count == 0 {
                path.push(homeActiveSpaceManager.workspaceInfo)
            }
            
            path.push(data)
            editorPath = path
        } else {
            editorPath.push(data)
        }
    }
    
    private func switchSpace(info newInfo: AccountInfo) {
        Task {
            guard currentSpaceId != newInfo.accountSpaceId else { return }
            // Backup current
            if let currentSpaceId = currentSpaceId {
                paths[currentSpaceId] = editorPath
            }
            // Restore New
            var path = paths[newInfo.accountSpaceId] ?? HomePath()
            if path.count == 0 {
                path.push(newInfo)
            }
            
            if currentSpaceId.isNotNil {
                await dismissAllPresented?()
            }
            
            do {
                if let screen = try await getLastOpenedScreen(newInfo: newInfo) {
                    path.push(screen)
                }
            }
            
            currentSpaceId = newInfo.accountSpaceId
            editorPath = path
            info = newInfo
        }
    }
    
    private func getLastOpenedScreen(newInfo: AccountInfo) async throws -> EditorScreenData? {
        // do NOT restore last opened screen if user have more then one space (business req.)
        guard workspacesStorage.allWorkspaces.count == 1 else { return nil }
        guard currentSpaceId.isNil, let lastOpenPage = userDefaults.getLastOpenedScreen(spaceId: newInfo.accountSpaceId) else { return nil }
        
        guard let objectId = lastOpenPage.objectId else { return lastOpenPage }
        
        let document = documentsProvider.document(objectId: objectId, mode: .preview)
        try await document.open()
        // Check space is deleted or switched
        if document.spaceId == newInfo.accountSpaceId {
            return lastOpenPage
        }
        
        return nil
    }
}
