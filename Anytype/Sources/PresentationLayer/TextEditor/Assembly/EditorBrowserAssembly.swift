import SwiftUI
import BlocksModels
import Combine

final class EditorBrowserAssembly {
    
    func editor(data: EditorScreenData, model: HomeViewModel) -> some View {
        EditorViewRepresentable(data: data, model: model).eraseToAnyView()
    }
    
    func buildEditorBrowser(data: EditorScreenData) -> EditorBrowserController {
        let browser = EditorBrowserController()

        let (page, router) = EditorAssembly(browser: browser)
            .buildEditorModule(data: data)
        
        browser.childNavigation = navigationStack(rootPage: page)
        browser.router = router
        
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
