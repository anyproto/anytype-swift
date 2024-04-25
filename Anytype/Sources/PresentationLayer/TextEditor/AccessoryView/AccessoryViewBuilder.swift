import UIKit
import Services
import AnytypeCore

struct AccessoryViewBuilder {
    @MainActor
    static func accessoryState(
        actionHandler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol,
        document: BaseDocumentProtocol,
        typesService: TypesServiceProtocol
    ) -> (AccessoryViewStateManager, ChangeTypeAccessoryViewModel) {
        let mentionsModule = MentionAssembly().controller(document: document)

        
        let mentionsView = MentionView(mentionsController: mentionsModule.0, frame: CGRect(origin: .zero, size: menuActionsViewSize))
        
        mentionsModule.0.dismissAction = { [weak mentionsView] in
            mentionsView?.dismissHandler?()
        }
        
        let cursorModeAccessoryViewModel = CursorModeAccessoryViewModel()
        
        let markupViewModel = MarkupAccessoryViewModel()
        
        let changeTypeViewModel = ChangeTypeAccessoryViewModel(
            router: router,
            handler: actionHandler,
            typesService: ServiceLocator.shared.typesService(),
            document: document
        )
        let typeListViewModel = HorizonalTypeListViewModel(
            itemProvider: changeTypeViewModel, 
            onSearchTap: { [weak changeTypeViewModel] in
                changeTypeViewModel?.onSearchTap()
            },
            onPasteTap: { [weak changeTypeViewModel] in
                changeTypeViewModel?.onTypeSelected?(.createFromPasteboard)
            }
        )
        let horizontalTypeListView = HorizonalTypeListView(viewModel: typeListViewModel)
        
        let changeTypeView = ChangeTypeAccessoryView(
            viewModel: changeTypeViewModel,
            changeTypeView: horizontalTypeListView.asUIView()
        )
        
        let cursorModeAccessoryView = CursorModeAccessoryView(viewModel: cursorModeAccessoryViewModel)
        let markupModeAccessoryView = MarkupAccessoryView(viewModel: markupViewModel)
        
        let slashMenuViewModel = SlashMenuViewModel(
            detailsMenuBuilder: SlashMenuCellDataBuilder(),
            itemsBuilder: SlashMenuItemsBuilder(typesService: typesService)
        )
        let slashMenuView = SlashMenuAssembly.menuView(
            size: menuActionsViewSize,
            viewModel: slashMenuViewModel
        )
        
        let accessoryViewSwitcher = AccessoryViewSwitcher(
            document: document,
            mentionsView: mentionsView,
            slashMenuView: slashMenuView,
            cursorModeAccessoryView: cursorModeAccessoryView,
            markupAccessoryView: markupModeAccessoryView,
            changeTypeView: changeTypeView
        )
        
        slashMenuViewModel.resetSlashMenuHandler = { [weak accessoryViewSwitcher] in
            accessoryViewSwitcher?.showDefaultView()
        }
        
        let stateManager = AccessoryViewStateManagerImpl(
            document: document,
            switcher: accessoryViewSwitcher,
            markupChanger: BlockMarkupChanger(),
            cursorModeViewModel: cursorModeAccessoryViewModel,
            slashMenuViewModel: slashMenuViewModel,
            mentionsViewModel: mentionsModule.1,
            markupAccessoryViewModel: markupViewModel
        )
        
        mentionsModule.1.onSelect = { [weak stateManager] in
            stateManager?.selectMention($0)
        }
        
        return (stateManager, changeTypeViewModel)

    }

    @MainActor
    private static let menuActionsViewSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.isFourInch ? 160 : 215
    )
}


