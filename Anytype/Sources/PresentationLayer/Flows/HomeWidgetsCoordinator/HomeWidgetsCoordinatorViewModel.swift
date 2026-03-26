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
    var showHomepagePicker = false

    @Injected(\.legacySetObjectCreationCoordinator) @ObservationIgnored
    private var setObjectCreationCoordinator: any SetObjectCreationCoordinatorProtocol

    init(info: AccountInfo) {
        self.spaceInfo = info
    }

    func onAppear() {
        let spaceView = Container.shared.spaceViewsStorage().spaceView(spaceId: spaceInfo.accountSpaceId)
        var homepageNotSet = spaceView?.homepage.isEmpty == true
        #if DEBUG
        // TODO: Remove when middleware stops setting "widgets" as default homepage for new spaces
        homepageNotSet = homepageNotSet || spaceView?.homepage == "widgets"
        #endif
        if homepageNotSet, !showHomepagePicker {
            showHomepagePicker = true
        }
    }

    func onHomepagePickerFinished(result: HomepagePickerResult) {
        showHomepagePicker = false

        guard case .homepageSet(let value) = result, case .object(let details) = value else { return }
        pageNavigation?.open(details.screenData())
    }

    // MARK: - HomeWidgetsModuleOutput

    func onSpaceSelected() {
        pageNavigation?.open(.spaceInfo(.settings(spaceId: spaceInfo.accountSpaceId)))
    }

    func onCreateObjectType() {
        createTypeData = CreateObjectTypeData(spaceId: spaceInfo.accountSpaceId, name: "", route: .screenWidget)
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
