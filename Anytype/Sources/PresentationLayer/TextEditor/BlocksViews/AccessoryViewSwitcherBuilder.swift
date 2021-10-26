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
            handler: actionHandler,
            searchService: SearchService(),
            document: document
        )

        let changeTypeViewModel = ChangeTypeAccessoryItemViewModel(itemProvider: accessoryViewModel) { [weak router] in
            router?.showTypesSearch(onSelect: { id in
                actionHandler.setObjectTypeUrl(id)
            })
        }
        let changeTypeView = ChangeTypeAccessoryView(
            viewModel: changeTypeViewModel
        )

        let accessoryView = EditorAccessoryView(
            viewModel: accessoryViewModel,
            changeTypeView: changeTypeView.asUIView()
        )
        
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
            handler: actionHandler
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
