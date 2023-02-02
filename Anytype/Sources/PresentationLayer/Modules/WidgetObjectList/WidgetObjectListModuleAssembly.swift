import Foundation
import SwiftUI

protocol WidgetObjectListModuleAssemblyProtocol: AnyObject {
    
    // Common
    func make() -> UIViewController
    
    // Specific
    func makeFavorites() -> UIViewController
    func makeRecent() -> UIViewController
    func makeSets() -> UIViewController
    func makeBin() -> UIViewController
}

final class WidgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol {
    
    func makeFavorites() -> UIViewController {
        return make()
    }
    
    func makeRecent() -> UIViewController {
        return make()
    }
    
    func makeSets() -> UIViewController {
        return make()
    }
    
    func makeBin() -> UIViewController {
        return make()
    }
    
    // MARK: - Private
    
    func make() -> UIViewController {
        let view = WidgetObjectListView()
        return WidgetObjectListHostingController(rootView: view)
    }
}
