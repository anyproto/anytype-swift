import UIKit
import BlocksModels

struct AccessoryViewBuilder {
    static func accessoryState(
        actionHandler: BlockActionHandlerProtocol,
        router: EditorRouter,
        document: BaseDocumentProtocol
    ) -> AccessoryViewStateManager {
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
        let markupView = MarkupAccessoryView()
        let editModeAccessoryView = EditModeAccessoryView(cursorModeView: accessoryView, markupModeView: markupView)

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
            accessoryView: editModeAccessoryView,
            changeTypeView: changeTypeView,
            urlInputView: urlInputView,
            document: document
        )

        // set delegate
        let stateManager = AccessoryViewStateManager(switcher: accessoryViewSwitcher, handler: actionHandler)
        mentionsView.delegate = stateManager
        accessoryView.setDelegate(stateManager)

        return stateManager
    }
    
    private static let menuActionsViewSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.isFourInch ? 160 : 215
    )
}
