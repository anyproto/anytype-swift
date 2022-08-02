import SwiftUI
import BlocksModels
import Combine

final class EditorBrowserAssembly {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(coordinatorsDI: CoordinatorsDIProtocol) {
        self.coordinatorsDI = coordinatorsDI
    }
    
    func editor(data: EditorScreenData, model: HomeViewModel) -> some View {
        EditorViewRepresentable(data: data, model: model, editorBrowserAssembly: self).eraseToAnyView()
    }
    
    func buildEditorBrowser(data: EditorScreenData) -> EditorBrowserController {
        let browser = EditorBrowserController()

        let (page, router) = coordinatorsDI.editor
            .buildEditorModule(browser: browser, data: data, editorBrowserViewInput: browser)
        
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
