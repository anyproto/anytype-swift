import Foundation
import SwiftUI

@MainActor
protocol SpaceShareModuleAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

@MainActor
final class SpaceShareModuleAssembly: SpaceShareModuleAssemblyProtocol {
    
    nonisolated init() {}
    
    // MARK: - SpaceShareModuleAssemblyProtocol
    
    func make() -> AnyView {
        return SpaceShareView(model: SpaceShareViewModel()).eraseToAnyView()
    }
}
