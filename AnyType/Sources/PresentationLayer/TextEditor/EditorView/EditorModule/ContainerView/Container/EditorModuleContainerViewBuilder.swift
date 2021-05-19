import Foundation
import UIKit
import SwiftUI


enum EditorModuleContainerViewBuilder {
    static func childComponent(id: String) -> EditorModuleContentModule {
        EditorModuleContentViewBuilder.сontent(id: id)
    }
    
    static func view(id: String) -> EditorModuleContainerViewController {
        let childComponent = self.childComponent(id: id)
        
        let childViewController = childComponent.0
        
        let childPresenter = childComponent.1
        
        childPresenter.navigationItem = windowHolder?.rootNavigationController.navigationBar.topItem
        
        let router = DocumentViewCompoundRouter()
        router.configured(userActionsStream: childComponent.2)
        
        let viewModel = EditorModuleContainerViewModel(router: router)
        
        let viewController = EditorModuleContainerViewController(
            viewModel: viewModel, childViewController: childViewController
        )

        windowHolder?.rootNavigationController.delegate = viewController
        
        return viewController
    }
}
