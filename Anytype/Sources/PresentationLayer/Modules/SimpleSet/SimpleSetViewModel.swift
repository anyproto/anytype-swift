import Foundation
import Services

@MainActor
protocol SimpleSetModuleOutput: AnyObject {
    func onObjectSelected(screenData: ScreenData)
}

@MainActor
final class SimpleSetViewModel: ObservableObject {
    
    private let objectId: String
    private let spaceId: String
    private weak var output: (any SimpleSetModuleOutput)?
    
    init(objectId: String, spaceId: String, output: (any SimpleSetModuleOutput)?) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.output = output
    }
  
}
