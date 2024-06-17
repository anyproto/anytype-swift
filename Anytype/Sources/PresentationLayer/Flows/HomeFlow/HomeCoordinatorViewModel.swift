import Foundation
import SwiftUI
import Combine
import Services
import AnytypeCore
import DeepLinks

@MainActor
final class HomeCoordinatorViewModel: ObservableObject,
                                             HomeWidgetsModuleOutput, CommonWidgetModuleOutput,
                                             HomeBottomNavigationPanelModuleOutput,
                                             SetObjectCreationCoordinatorOutput {
    
    // MARK: - DI
    
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: DefaultObjectCreationServiceProtocol
    @Injected(\.blockService)
    private var blockService: BlockServiceProtocol
    @Injected(\.pasteboardBlockService)
    private var pasteboardBlockService: PasteboardBlockServiceProtocol
    @Injected(\.objectTypeProvider)
    private var typeProvider: ObjectTypeProviderProtocol
    @Injected(\.appActionStorage)
    private var appActionsStorage: AppActionStorage
    @Injected(\.workspaceStorage)
    private var workspacesStorage: WorkspacesStorageProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: DocumentsProviderProtocol
    
    @Injected(\.legacySetObjectCreationCoordinator)
    private var setObjectCreationCoordinator: SetObjectCreationCoordinatorProtocol
    
    // MARK: - State
    
    private var viewLoaded = false
    private var subscriptions = [AnyCancellable]()
    private var paths = [String: HomePath]()
    private var dismissAllPresented: DismissAllPresented?
    
    @Published var showChangeSourceData: WidgetChangeSourceSearchModuleModel?
    @Published var showChangeTypeData: WidgetTypeChangeData?
    @Published var showSearchData: ObjectSearchModuleData?
    @Published var showGlobalSearchData: GlobalSearchModuleData?
    @Published var showSpaceSwitch: Bool = false
    @Published var showCreateWidgetData: CreateWidgetCoordinatorModel?
    @Published var showSpaceSettings: Bool = false
    @Published var showSharing: Bool = false
    @Published var showSpaceManager: Bool = false
    @Published var showGalleryImport: GalleryInstallationData?
    @Published var showMembershipNameSheet: MembershipTier?
    @Published var showSpaceShareTip: Bool = false
    
    @Published var editorPath = HomePath() {
        didSet { UserDefaultsConfig.lastOpenedPage = editorPath.lastPathElement as? EditorScreenData }
    }
    @Published var showTypeSearchForObjectCreation: Bool = false
    @Published var toastBarData = ToastBarData.empty
    @Published var pathChanging: Bool = false
    @Published var keyboardToggle: Bool = false
    @Published var spaceJoinData: SpaceJoinModuleData?
    @Published var info: AccountInfo?
    
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

    init() {
        
        membershipStatusSubscription = Container.shared
            .membershipStatusStorage.resolve()
            .statusPublisher.receiveOnMain()
            .sink { [weak self] membership in
                guard membership.status == .pendingRequiresFinalization else { return }
                
                self?.showMembershipNameSheet = membership.tier
            }
    }

    func onAppear() {
        guard !viewLoaded else { return }
        viewLoaded = true
        
        activeWorkspaceStorage
            .workspaceInfoPublisher
            .receiveOnMain()
            .sink { [weak self] newInfo in
                self?.switchSpace(info: newInfo)
            }
            .store(in: &subscriptions)
    }
    
    func startDeepLinkTask() async {
        for await action in appActionsStorage.$action.values {
            if let action {
                try? await handleAppAction(action: action)
                appActionsStorage.action = nil
            }
        }
    }
    
    func setDismissAllPresented(dismissAllPresented: DismissAllPresented) {
        self.dismissAllPresented = dismissAllPresented
    }
    
    func typeSearchForObjectCreationModule() -> TypeSearchForNewObjectCoordinatorView {        
        TypeSearchForNewObjectCoordinatorView { [weak self] details in
            guard let self else { return }
            openObject(screenData: details.editorScreenData())
        }
    }
    
    // MARK: - HomeWidgetsModuleOutput
    
    func onCreateWidgetSelected(context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
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
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeSourceData = nil
            }
        )
    }

    func onChangeWidgetType(widgetId: String, context: AnalyticsWidgetContext) {
        showChangeTypeData = WidgetTypeChangeData(
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeTypeData = nil
            }
        )
    }
    
    func onAddBelowWidget(widgetId: String, context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
            position: .below(widgetId: widgetId),
            context: context
        )
    }
    
    func onSpaceSelected() {
        showSpaceSettings.toggle()
    }
    
    func onCreateObjectInSetDocument(setDocument: SetDocumentProtocol) {
        setObjectCreationCoordinator.startCreateObject(setDocument: setDocument, output: self, customAnalyticsRoute: .widget)
    }
    
    func onManageSpacesSelected() {
        showSpaceManager = true
    }
    
    // MARK: - HomeBottomNavigationPanelModuleOutput
    
    func onSearchSelected() {        
        if FeatureFlags.newGlobalSearch {
            showGlobalSearchData = GlobalSearchModuleData(
                spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                onSelect: { [weak self] screenData in
                    self?.openObject(screenData: screenData)
                }
            )
        } else {
            showSearchData = ObjectSearchModuleData(
                spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                title: nil,
                onSelect: { [weak self] data in
                    self?.openObject(screenData: data.editorScreenData)
                }
            )
        }
    }
    
    func onCreateObjectSelected(screenData: EditorScreenData) {
        UISelectionFeedbackGenerator().selectionChanged()
        openObject(screenData: screenData)
    }

    func onProfileSelected() {
        showSpaceSwitch.toggle()
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

    // MARK: - SetObjectCreationCoordinatorOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pushSync(data: data)
    }
    
    // MARK: - Private
    
    private func openObject(screenData: EditorScreenData) {
        pushSync(data: screenData)
    }
    
    private func createAndShowDefaultObject(route: AnalyticsEventsRouteKind) {
        Task {
            let details = try await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: route)
            openObject(screenData: details.editorScreenData())
        }
    }
    
    private func createAndShowNewObject(
        typeId: String,
        route: AnalyticsEventsRouteKind
    ) {
        do {
            let type = try typeProvider.objectType(id: typeId)
            createAndShowNewObject(type: type, route: route)
        } catch {
            anytypeAssertionFailure("No object provided typeId", info: ["typeId": typeId])
            createAndShowDefaultObject(route: route)
        }
    }

    private func createAndShowNewObject(
        type: ObjectType,
        route: AnalyticsEventsRouteKind
    ) {
        Task {
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.uniqueKey,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: true,
                spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                origin: .none,
                templateId: type.defaultTemplateId
            )
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: route)
            
            openObject(screenData: details.editorScreenData())
        }
    }
    
    private func handleAppAction(action: AppAction) async throws {
        keyboardToggle.toggle()
        switch action {
        case .createObjectFromQuickAction(let typeId):
            createAndShowNewObject(typeId: typeId, route: .homeScreen)
        case .deepLink(let deepLink):
            try await handleDeepLink(deepLink: deepLink)
        }
    }
    
    private func handleDeepLink(deepLink: DeepLink) async throws {
        await dismissAllPresented?()
        
        switch deepLink {
        case .createObjectFromWidget:
            createAndShowDefaultObject(route: .widget)
        case .showSharingExtension:
            showSharing = true
        case .spaceSelection:
            showSpaceSwitch = true
        case let .galleryImport(type, source):
            showGalleryImport = GalleryInstallationData(type: type, source: source)
        case .invite(let cid, let key):
            spaceJoinData = SpaceJoinModuleData(cid: cid, key: key)
        case .object(let objectId, _):
            let document = documentsProvider.document(objectId: objectId, forPreview: true)
            try await document.openForPreview()
            guard let editorData = document.details?.editorScreenData() else { return }
            try await push(data: editorData)
        case .spaceShareTip:
            showSpaceShareTip = true
        }
    }
    
    private func pushSync(data: EditorScreenData) {
        Task { try await push(data: data) }
    }
        
    private func push(data: EditorScreenData) async throws {
        guard let objectId = data.objectId else {
            editorPath.push(data)
            return
        }
        let document = documentsProvider.document(objectId: objectId, forPreview: true)
        try await document.openForPreview()
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
            try await activeWorkspaceStorage.setActiveSpace(spaceId: spaceId)
            
            var path = paths[spaceId] ?? HomePath()
            if path.count == 0 {
                path.push(activeWorkspaceStorage.workspaceInfo)
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
            
            do {
                // Restore last open page
                if currentSpaceId.isNil, let lastOpenPage = UserDefaultsConfig.lastOpenedPage {
                    if let objectId = lastOpenPage.objectId {
                        let document = documentsProvider.document(objectId: objectId, forPreview: true)
                        try await document.openForPreview()
                        // Check space is deleted or switched
                        if document.spaceId == newInfo.accountSpaceId {
                            path.push(lastOpenPage)
                        }
                    } else {
                        path.push(lastOpenPage)
                    }
                }
            }
            
            currentSpaceId = newInfo.accountSpaceId
            editorPath = path
            info = newInfo
        }
    }
}
