import Foundation
import SwiftUI

protocol WidgetObjectListModuleAssemblyProtocol: AnyObject {
    
    // Common
    func make() -> AnyView
    
    // Specific
    func makeFavorites() -> AnyView
    func makeRecent() -> AnyView
    func makeSets() -> AnyView
    func makeBin() -> AnyView
}

final class WidgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol {
    
    func makeFavorites() -> AnyView {
        return make()
    }
    
    func makeRecent() -> AnyView {
        return make()
    }
    
    func makeSets() -> AnyView {
        return make()
    }
    
    func makeBin() -> AnyView {
        return make()
    }
    
    // MARK: - Private
    
    func make() -> AnyView {
        return WidgetObjectListView().eraseToAnyView()
    }
}
