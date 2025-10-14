import Foundation

@MainActor
protocol CommonWidgetModuleOutput: AnyObject {
    func onObjectSelected(screenData: ScreenData)
    func onChangeWidgetType(widgetId: String, context: AnalyticsWidgetContext)
    func onSpaceSelected()
    func onCreateObjectInSetDocument(setDocument: some SetDocumentProtocol)
    func showDeleteSystemWidgetAlert(data: DeleteSystemWidgetConfirmationData)
}
