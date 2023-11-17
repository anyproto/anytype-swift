import Services
import SwiftUI

@MainActor
protocol SearchModuleAssemblyProtocol {
    func makeObjectSearch(
        data: SearchModuleModel
    ) -> AnyView
    
    func makeSpaceSearch(
        data: SearchSpaceModel
    ) -> AnyView
}
