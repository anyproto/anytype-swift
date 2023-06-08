import Foundation

@MainActor
protocol CommonWidgetModuleOutput: AnyObject {
    func onObjectSelected(screenData: EditorScreenData)
    func onChangeSource(widgetId: String, context: AnalyticsWidgetContext)
    func onChangeWidgetType(widgetId: String, context: AnalyticsWidgetContext)
    func onAddBelowWidget(widgetId: String, context: AnalyticsWidgetContext)
}
