import UIKit
import BlocksModels

struct AccessoryViewSwitcherBuilder {
    func accessoryViewSwitcher(
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

        let accessoryViewSwitcher = AccessoryViewSwitcher(
            mentionsView: mentionsView,
            slashMenuView: slashMenuView,
            accessoryView: accessoryView,
            changeTypeView: changeTypeView,
            handler: actionHandler,
            document: document
        )
        
        mentionsView.delegate = accessoryViewSwitcher
        accessoryViewModel.delegate = accessoryViewSwitcher
        
        return accessoryViewSwitcher
    }
    
    private let menuActionsViewSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.isFourInch ? 160 : 215
    )
}
