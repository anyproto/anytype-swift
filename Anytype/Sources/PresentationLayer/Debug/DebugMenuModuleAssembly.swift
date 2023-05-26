import Foundation
import SwiftUI

protocol DebugMenuModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make() -> AnyView
}

final class DebugMenuModuleAssembly: DebugMenuModuleAssemblyProtocol {
    
    @MainActor
    func make() -> AnyView {
        return DebugMenu().eraseToAnyView()
    }
}
 
