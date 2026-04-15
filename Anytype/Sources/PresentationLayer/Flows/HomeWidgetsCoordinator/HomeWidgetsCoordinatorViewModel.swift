import SwiftUI
import DeepLinks
import Services
import Combine
import AnytypeCore

@MainActor
@Observable
final class HomeWidgetsCoordinatorViewModel: HomeWidgetsModuleOutput, SetObjectCreationCoordinatorOutput {

    let spaceInfo: AccountInfo
    @ObservationIgnored
    var pageNavigation: PageNavigation?

    var showChangeTypeData: WidgetTypeChangeData?
    var createTypeData: CreateObjectTypeData?
    var deleteSystemWidgetConfirmationData: DeleteSystemWidgetConfirmationData?
    var showGlobalSearchData: GlobalSearchModuleData?
    var spaceShareData: SpaceShareData?
    var qrCodeInviteData: URLIdentifiable?
    var showHomeChangePicker = false
    var showHomepagePicker = false

    @Injected(\.legacySetObjectCreationCoordinator) @ObservationIgnored
    private var setObjectCreationCoordinator: any SetObjectCreationCoordinatorProtocol
    @Injected(\.pendingShareService) @ObservationIgnored
    private var pendingShareService: any PendingShareServiceProtocol
    @Injected(\.participantSpacesStorage) @ObservationIgnored
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.pendingShareStorage) @ObservationIgnored
    private var pendingShareStorage: any PendingShareStorageProtocol

    init(info: AccountInfo) {
        self.spaceInfo = info
    }

    func startSpaceViewTask() async {
        guard FeatureFlags.createChannelFlow else { return }
        let spaceId = spaceInfo.accountSpaceId
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            let spaceView = participantSpaceView.spaceView
            let homepageNotSet = spaceView.homepage == .empty
            let canSetHomepage = participantSpaceView.canSetHomepage
            // 1-on-1 spaces have their homepage set by middleware; never prompt the picker.
            if homepageNotSet, canSetHomepage, !spaceView.isOneToOne, !showHomepagePicker {
                showHomepagePicker = true
            }
        }
    }

    func onHomepagePickerFinished(result: HomepagePickerResult) {
        showHomepagePicker = false
        guard case .homepageSet(let value) = result, case .object(let details) = value else { return }
        pageNavigation?.open(details.screenData())
    }

    func startPendingShareRetryTask() async {
        let spaceId = spaceInfo.accountSpaceId
        guard pendingShareStorage.pendingState(for: spaceId) != nil else { return }

        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            guard pendingShareStorage.pendingState(for: spaceId) != nil else { return }

            if participantSpaceView.spaceView.isActive {
                await pendingShareService.retryIfNeeded(spaceId: spaceId)
                if pendingShareStorage.pendingState(for: spaceId) == nil { return }
            }
        }
    }

    // MARK: - HomeWidgetsModuleOutput

    func onSpaceSelected() {
        pageNavigation?.open(.spaceInfo(.settings(spaceId: spaceInfo.accountSpaceId)))
    }

    func onCreateObjectType() {
        createTypeData = CreateObjectTypeData(spaceId: spaceInfo.accountSpaceId, name: "", route: .screenWidget)
    }

    func onChangeHome() {
        showHomeChangePicker = true
    }

    func onObjectSelected(screenData: ScreenData) {
        pageNavigation?.open(screenData)
    }

    func onChangeWidgetType(widgetId: String, context: AnalyticsWidgetContext) {
        showChangeTypeData = WidgetTypeChangeData(
            widgetObjectId: spaceInfo.widgetsId,
            widgetSpaceId: spaceInfo.accountSpaceId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeTypeData = nil
            }
        )
    }

    func onCreateObjectInSetDocument(setDocument: some SetDocumentProtocol) {
        setObjectCreationCoordinator.startCreateObject(
            setDocument: setDocument,
            mode: .fullscreen,
            output: self,
            customAnalyticsRoute: .widget
        )
    }

    func showDeleteSystemWidgetAlert(data: DeleteSystemWidgetConfirmationData) {
        deleteSystemWidgetConfirmationData = data
    }

    func onSpaceChatMembersSelected(spaceId: String, route: SettingsSpaceShareRoute) {
        spaceShareData = SpaceShareData(spaceId: spaceId, route: route)
    }

    func onSpaceChatShowQrCodeSelected(url: URL) {
        qrCodeInviteData = url.identifiable
    }

    // MARK: - SetObjectCreationCoordinatorOutput

    func showEditorScreen(data: ScreenData) {
        pageNavigation?.open(data)
    }
}

// MARK: - HomeBottomNavigationPanelModuleOutput

extension HomeWidgetsCoordinatorViewModel: HomeBottomNavigationPanelModuleOutput {
    func onSearchSelected() {
        showGlobalSearchData = GlobalSearchModuleData(spaceId: spaceInfo.accountSpaceId) { [weak self] screenData in
            self?.pageNavigation?.open(screenData)
        }
    }

    func onCreateObjectSelected(screenData: ScreenData) {
        pageNavigation?.open(screenData)
    }

    func onAddMediaSelected(spaceId: String) {
        anytypeAssertionFailure("Unsupported method: onAddMediaSelected")
    }

    func onCameraSelected(spaceId: String) {
        anytypeAssertionFailure("Unsupported method: onCameraSelected")
    }

    func onAddFilesSelected(spaceId: String) {
        anytypeAssertionFailure("Unsupported method: onAddFilesSelected")
    }

    func onShowWidgetsOverlay(spaceId: String) {
        anytypeAssertionFailure("Unsupported method: onShowWidgetsOverlay")
    }
}
