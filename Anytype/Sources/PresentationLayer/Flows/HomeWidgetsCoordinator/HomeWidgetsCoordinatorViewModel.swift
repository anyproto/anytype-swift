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
    var showCreateWidgetData: CreateWidgetCoordinatorModel?
    var createTypeData: CreateObjectTypeData?
    var deleteSystemWidgetConfirmationData: DeleteSystemWidgetConfirmationData?
    
    @Injected(\.legacySetObjectCreationCoordinator) @ObservationIgnored
    private var setObjectCreationCoordinator: any SetObjectCreationCoordinatorProtocol
    
    init(info: AccountInfo) {
        self.spaceInfo = info
    }
    
    func onFinishCreateSource(screenData: ScreenData?) {
        if let screenData {
            pageNavigation?.open(screenData)
        }
    }
    
    // MARK: - HomeWidgetsModuleOutput
    
    func onSpaceSelected() {
        pageNavigation?.open(.spaceInfo(.settings(spaceId: spaceInfo.accountSpaceId)))
    }
    
    func onCreateWidgetSelected(context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: spaceInfo.accountSpaceId,
            widgetObjectId: spaceInfo.widgetsId,
            position: .end,
            context: context
        )
    }
    
    func onCreateObjectType() {
        createTypeData = CreateObjectTypeData(spaceId: spaceInfo.accountSpaceId, name: "")
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
    
    func onAddBelowWidget(widgetId: String, context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: spaceInfo.accountSpaceId,
            widgetObjectId: spaceInfo.widgetsId,
            position: .below(widgetId: widgetId),
            context: context
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
    
    // MARK: - SetObjectCreationCoordinatorOutput
    
    func showEditorScreen(data: ScreenData) {
        pageNavigation?.open(data)
    }
}
