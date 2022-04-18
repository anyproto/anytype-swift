import UIKit
import BlocksModels

struct AccessoryViewBuilder {
    static func accessoryState(
        actionHandler: BlockActionHandlerProtocol,
        router: EditorRouter,
        pasteboardService: PasteboardServiceProtocol,
        document: BaseDocumentProtocol
    ) -> AccessoryViewStateManager {
        let mentionsView = MentionView(frame: CGRect(origin: .zero, size: menuActionsViewSize))
        
        let cursorModeAccessoryViewModel = CursorModeAccessoryViewModel(
            router: router,
            handler: actionHandler
        )
        
        let markupViewModel = MarkupAccessoryViewModel(
            document: document,
            actionHandler: actionHandler,
            router: router
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

        let cursorModeAccessoryView = CursorModeAccessoryView(viewModel: cursorModeAccessoryViewModel)
        let markupModeAccessoryView = MarkupAccessoryView(viewModel: markupViewModel)

        let slashMenuViewModel = SlashMenuViewModel(
            handler: SlashMenuActionHandler(
                actionHandler: actionHandler,
                router: router,
                pasteboardService: pasteboardService
            )
        )
        let slashMenuView = SlashMenuAssembly.menuView(
            size: menuActionsViewSize,
            viewModel: slashMenuViewModel
        )

        let accessoryViewSwitcher = AccessoryViewSwitcher(
            mentionsView: mentionsView,
            slashMenuView: slashMenuView,
            cursorModeAccessoryView: cursorModeAccessoryView,
            markupAccessoryView: markupModeAccessoryView,
            changeTypeView: changeTypeView,
            document: document
        )

        slashMenuViewModel.resetSlashMenuHandler = { [weak accessoryViewSwitcher] in
            accessoryViewSwitcher?.restoreDefaultState()

        }

        // set delegate
        let stateManager = AccessoryViewStateManagerImpl(switcher: accessoryViewSwitcher, handler: actionHandler)
        mentionsView.delegate = stateManager
        cursorModeAccessoryView.setDelegate(stateManager)

        return stateManager
    }
    
    private static let menuActionsViewSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.isFourInch ? 160 : 215
    )
}
