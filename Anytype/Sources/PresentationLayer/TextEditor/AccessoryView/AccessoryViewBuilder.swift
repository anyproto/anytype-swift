import UIKit
import BlocksModels

struct AccessoryViewBuilder {
    static func accessoryState(
        actionHandler: EditorActionHandlerProtocol,
        router: EditorRouter,
        document: BaseDocumentProtocol
    ) -> AccessoryViewStateManager {
        let switcher = buildSwitcher(actionHandler: actionHandler, router: router, document: document)
        let stateManager = AccessoryViewStateManagerImpl(switcher: switcher, handler: actionHandler)
        switcher.setDelegate(stateManager)
        
        return stateManager
    }
    
    private static func buildSwitcher(
        actionHandler: EditorActionHandlerProtocol,
        router: EditorRouter,
        document: BaseDocumentProtocol
    ) -> AccessoryViewSwitcher {
        let mentionsView = MentionView(frame: CGRect(origin: .zero, size: menuActionsViewSize))
        
        let accessoryViewModel = EditorAccessoryViewModel(
            router: router,
            handler: actionHandler
        )

        let changeTypeViewModel = ChangeTypeAccessoryViewModel(
            router: router,
            handler: actionHandler,
            searchService: SearchService(),
            document: document
        )

        let typeListViewModel = HorizonalTypeListViewModel(
            itemProvider: changeTypeViewModel
        ) { [weak router, weak actionHandler] in
            router?.showTypesSearch(onSelect: { id in
                actionHandler?.setObjectTypeUrl(id)
            })
        }

        let horizontalTypeListView = HorizonalTypeListView(viewModel: typeListViewModel)

        let changeTypeView = ChangeTypeAccessoryView(
            viewModel: changeTypeViewModel,
            changeTypeView: horizontalTypeListView.asUIView()
        )

        let accessoryView = EditorAccessoryView(viewModel: accessoryViewModel)
        
        let slashMenuViewModel = SlashMenuViewModel(
            handler: SlashMenuActionHandler(
                actionHandler: actionHandler,
                router: router
            )
        )
        let slashMenuView = SlashMenuAssembly.menuView(
            size: menuActionsViewSize,
            viewModel: slashMenuViewModel
        )
        let urlInputView = URLInputAccessoryView(handler: actionHandler)

        let accessoryViewSwitcher = AccessoryViewSwitcher(
            mentionsView: mentionsView,
            slashMenuView: slashMenuView,
            accessoryView: accessoryView,
            changeTypeView: changeTypeView,
            urlInputView: urlInputView,
            document: document
        )
        
        return accessoryViewSwitcher
    }
    
    private static let menuActionsViewSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.isFourInch ? 160 : 215
    )
}
