import Foundation
import UIKit
import SwiftUI


enum EditorModuleContainerViewBuilder {
    
    static func makeView(with id: String) -> EditorModuleContainerViewController {
        let (childViewController, userActionsStream) = childComponent(id: id)
        
        let router = DocumentViewCompoundRouter()
        router.configure(userActionsStream: userActionsStream)
        
        let viewModel = EditorModuleContainerViewModel(router: router)
        
        let viewController = EditorModuleContainerViewController(
            viewModel: viewModel,
            childViewController: childViewController
        )

        windowHolder?.rootNavigationController.delegate = viewController
        
        return viewController
    }
    
    static func childComponent(id: String) -> EditorModuleContentModule {
        EditorModuleContentViewBuilder.сontent(id: id)
    }
    
}
