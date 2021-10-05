import SwiftUI
import BlocksModels
import Combine

final class EditorAssembly {
    
    func documentView(blockId: BlockId) -> some View {
        EditorViewRepresentable(blockId: blockId)
            .eraseToAnyView()
    }
    
    func buildRootEditor(blockId: BlockId) -> EditorBrowserController {
        let browser =  EditorBrowserController()

        let (page, router) = EditorPageAssembly(browser: browser).buildEditorModule(pageId: blockId)
        
        browser.childNavigation = navigationStack(rootPage: page)
        browser.router = router
        
        browser.setup()
        
        return browser
    }
    
    private func navigationStack(rootPage: EditorPageController) -> UINavigationController {
        let navigationController = UINavigationController(
            rootViewController: rootPage
        )

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navigationController.modifyBarAppearance(navBarAppearance)

        return navigationController
    }
}
