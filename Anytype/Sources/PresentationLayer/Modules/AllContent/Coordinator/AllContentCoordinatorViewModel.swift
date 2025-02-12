import Foundation

@MainActor
final class AllContentCoordinatorViewModel: ObservableObject, AllContentModuleOutput {
    
    let spaceId: String
    private weak var output: (any WidgetObjectListCommonModuleOutput)?
    
    init(spaceId: String, output: (any WidgetObjectListCommonModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    // MARK: - AllContentModuleOutput
    
    func onObjectSelected(screenData: ScreenData) {
        output?.onObjectSelected(screenData: screenData)
    }
}
