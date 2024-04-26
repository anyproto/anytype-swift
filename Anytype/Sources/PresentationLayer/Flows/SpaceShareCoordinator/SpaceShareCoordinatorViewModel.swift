import Foundation
import SwiftUI

@MainActor
final class SpaceShareCoordinatorViewModel: ObservableObject {
    
    private let spaceShareModule: SpaceShareModuleAssemblyProtocol
    
    init(spaceShareModule: SpaceShareModuleAssemblyProtocol) {
        self.spaceShareModule = spaceShareModule
    }
    
    func shareModule() -> AnyView {
        return spaceShareModule.make()
    }
}
