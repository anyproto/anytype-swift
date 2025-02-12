import Foundation

@MainActor
protocol CommonWidgetModuleOutput: AnyObject {
    func onObjectSelected(screenData: ScreenData)
    func onChangeSource(widgetId: String, context: AnalyticsWidgetContext)
    func onChangeWidgetType(widgetId: String, context: AnalyticsWidgetContext)
    func onAddBelowWidget(widgetId: String, context: AnalyticsWidgetContext)
    func onSpaceSelected()
    func onCreateObjectInSetDocument(setDocument: some SetDocumentProtocol)
}
