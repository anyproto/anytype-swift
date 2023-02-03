import SwiftUI
import BlocksModels
import Combine

final class EditorBrowserAssembly {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(coordinatorsDI: CoordinatorsDIProtocol, serviceLocator: ServiceLocator) {
        self.coordinatorsDI = coordinatorsDI
        self.serviceLocator = serviceLocator
    }
    
    func editor(data: EditorScreenData, model: HomeViewModel) -> some View {
        EditorViewRepresentable(data: data, model: model, editorBrowserAssembly: self).eraseToAnyView()
    }
    
    func buildEditorBrowser(data: EditorScreenData, router: EditorPageOpenRouterProtocol? = nil) -> EditorBrowserController {
        let browser = EditorBrowserController(dashboardService: serviceLocator.dashboardService())

        let (page, moduleRouter) = coordinatorsDI.editor()
            .buildEditorModule(browser: browser, data: data)
        
        browser.childNavigation = navigationStack(rootPage: page)
        browser.router = router ?? moduleRouter
        
        browser.setup()
        
        return browser
    }
    
    private func navigationStack(rootPage: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(
            rootViewController: rootPage
        )

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navigationController.modifyBarAppearance(navBarAppearance)

        return navigationController
    }
}
