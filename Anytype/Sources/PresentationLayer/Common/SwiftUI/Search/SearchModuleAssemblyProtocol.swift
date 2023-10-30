import Services
import SwiftUI

protocol SearchModuleAssemblyProtocol {
    func makeObjectSearch(
        data: SearchModuleModel
    ) -> AnyView
    
    func makeSpaceSearch(
        data: SearchSpaceModel
    ) -> AnyView
}
