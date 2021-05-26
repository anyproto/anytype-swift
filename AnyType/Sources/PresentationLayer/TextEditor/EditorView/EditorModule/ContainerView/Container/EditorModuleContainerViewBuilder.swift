import Foundation
import UIKit
import SwiftUI


enum EditorModuleContainerViewBuilder {
    static func childComponent(id: String) -> EditorModuleContentModule {
        EditorModuleContentViewBuilder.сontent(id: id)
    }
    
    static func view(id: String) -> EditorModuleContainerViewController {
        let (childViewController, userActionsStream)  = childComponent(id: id)
        
        let router = DocumentViewCompoundRouter()
        router.configured(userActionsStream: userActionsStream)
        
        let viewModel = EditorModuleContainerViewModel(router: router)
        
        let viewController = EditorModuleContainerViewController(
            viewModel: viewModel, childViewController: childViewController
        )

        windowHolder?.rootNavigationController.delegate = viewController
        
        return viewController
    }
}
