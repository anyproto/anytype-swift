import Foundation
import SwiftUI

protocol SpaceMembersModuleAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

final class SpaceMembersModuleAssembly: SpaceMembersModuleAssemblyProtocol {
    
    func make() -> AnyView {
        return SpaceMembersView(model: SpaceMembersViewModel()).eraseToAnyView()
    }
}
