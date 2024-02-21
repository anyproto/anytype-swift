import Foundation
import SwiftUI

protocol SpacesManagerModuleAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

final class SpacesManagerModuleAssembly: SpacesManagerModuleAssemblyProtocol {
    
    // MARK: - SpacesManagerModuleAssemblyProtocol
    
    func make() -> AnyView {
        SpacesManagerView(model: SpacesManagerViewModel()).eraseToAnyView()
    }
}
