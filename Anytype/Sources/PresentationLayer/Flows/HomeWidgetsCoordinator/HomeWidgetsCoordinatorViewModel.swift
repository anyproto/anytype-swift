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
    
    @Injected(\.legacySetObjectCreationCoordinator) @ObservationIgnored
    private var setObjectCreationCoordinator: any SetObjectCreationCoordinatorProtocol
    
    init(info: AccountInfo) {
        self.spaceInfo = info
    }
    
    // MARK: - HomeWidgetsModuleOutput
    
    func onSpaceSelected() {
        pageNavigation?.open(.spaceInfo(.settings(spaceId: spaceInfo.accountSpaceId)))
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
