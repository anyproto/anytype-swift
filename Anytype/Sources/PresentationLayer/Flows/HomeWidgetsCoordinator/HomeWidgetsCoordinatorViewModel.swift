import SwiftUI
import DeepLinks
import Services
import Combine
import AnytypeCore

@MainActor
final class HomeWidgetsCoordinatorViewModel: ObservableObject, HomeWidgetsModuleOutput, SetObjectCreationCoordinatorOutput {
    
    let spaceInfo: AccountInfo
    var pageNavigation: PageNavigation?
    
    @Published var showChangeSourceData: WidgetChangeSourceSearchModuleModel?
    @Published var showChangeTypeData: WidgetTypeChangeData?
    @Published var showCreateWidgetData: CreateWidgetCoordinatorModel?
    @Published var showSpaceSettingsData: AccountInfo?
    
    @Injected(\.legacySetObjectCreationCoordinator)
    private var setObjectCreationCoordinator: any SetObjectCreationCoordinatorProtocol
    
    init(data: HomeWidgetData) {
        self.spaceInfo = data.info
    }
    
    func onFinishCreateSource(screenData: ScreenData?) {
        if let screenData {
            pageNavigation?.open(screenData)
        }
    }
    
    func onFinishChangeSource(screenData: ScreenData?) {
        showChangeSourceData = nil
        if let screenData {
            pageNavigation?.open(screenData)
        }
    }
    
    // MARK: - HomeWidgetsModuleOutput
    
    func onSpaceSelected() {
        if FeatureFlags.newSettings {
            pageNavigation?.open(.settings(spaceInfo))
        } else {
            showSpaceSettingsData = spaceInfo
        }
    }
    
    func onCreateWidgetSelected(context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: spaceInfo.accountSpaceId,
            widgetObjectId: spaceInfo.widgetsId,
            position: .end,
            context: context
        )
    }
    
    func onObjectSelected(screenData: ScreenData) {
        pageNavigation?.open(screenData)
    }
    
    func onChangeSource(widgetId: String, context: AnalyticsWidgetContext) {
        showChangeSourceData = WidgetChangeSourceSearchModuleModel(
            widgetObjectId: spaceInfo.widgetsId,
            spaceId: spaceInfo.accountSpaceId,
            widgetId: widgetId,
            context: context
        )
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
        setObjectCreationCoordinator.startCreateObject(setDocument: setDocument, output: self, customAnalyticsRoute: .widget)
    }
    
    // MARK: - SetObjectCreationCoordinatorOutput
    
    func showEditorScreen(data: ScreenData) {
        pageNavigation?.open(data)
    }
}
