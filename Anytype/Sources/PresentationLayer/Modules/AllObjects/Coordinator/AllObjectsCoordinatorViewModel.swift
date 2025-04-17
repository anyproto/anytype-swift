import Foundation

@MainActor
final class AllObjectsCoordinatorViewModel: ObservableObject, AllObjectsModuleOutput {
    
    let spaceId: String
    private weak var output: (any WidgetObjectListCommonModuleOutput)?
    
    init(spaceId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    // MARK: - AllObjectsModuleOutput
    
    func onObjectSelected(screenData: ScreenData) {
        output?.onObjectSelected(screenData: screenData)
    }
}
