import Foundation

@MainActor
protocol HomeWidgetsModuleOutput: AnyObject, CommonWidgetModuleOutput {
    func onSpaceSelected()
    func onCreateObjectType()
    func onShowHomepagePicker()
    func onChangeHome()
}
