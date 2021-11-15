import SwiftUI
import BlocksModels
import Combine

enum EditorViewType {
    case page
    case set
}

final class EditorBrowserAssembly {
    
    func editor(blockId: BlockId, model: HomeViewModel) -> some View {
        EditorViewRepresentable(blockId: blockId, model: model).eraseToAnyView()
    }
    
    func buildEditorBrowser(blockId: BlockId, type: EditorViewType) -> EditorBrowserController {
        let browser = EditorBrowserController()

        let (page, router) = EditorAssembly(browser: browser)
            .buildEditorModule(pageId: blockId, type: type)
        
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
