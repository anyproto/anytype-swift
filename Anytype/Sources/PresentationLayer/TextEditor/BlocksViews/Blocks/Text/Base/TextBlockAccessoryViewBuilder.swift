import UIKit
import BlocksModels

final class TextBlockAccessoryViewBuilder {
    private let actionHandler: EditorActionHandlerProtocol
    
    init(actionHandler: EditorActionHandlerProtocol) {
        self.actionHandler = actionHandler
    }
    
    func accessoryViewSwitcher(
        textView: CustomTextView,
        delegate: TextViewDelegate & AccessoryViewSwitcherDelegate,
        contentType: BlockContentType
    ) -> AccessoryViewSwitcher {
        let mentionsView = MentionView(frame: CGRect(origin: .zero, size: menuActionsViewSize))
        
        let editorAccessoryhandler = EditorAccessoryViewActionHandler(delegate: delegate)
        let accessoryView = EditorAccessoryView(actionHandler: editorAccessoryhandler)
        
        let actionsHandler = SlashMenuActionsHandlerImp(actionHandler: actionHandler)
        let restrictions = BlockRestrictionsFactory().makeRestrictions(for: contentType)
        let items = BlockActionsBuilder(restrictions: restrictions).makeBlockActionsMenuItems()
        let assembly = SlashMenuAssembly(actionsHandler: actionsHandler)
        let slashMenuView = assembly.menuView(
            frame: CGRect(origin: .zero, size: menuActionsViewSize),
            menuItems: items
        )

        let accessoryViewSwitcher = AccessoryViewSwitcher(
            textView: textView.textView,
            delegate: delegate,
            mentionsView: mentionsView,
            slashMenuView: slashMenuView,
            accessoryView: accessoryView
        )
        
        mentionsView.delegate = accessoryViewSwitcher
        editorAccessoryhandler.customTextView = textView
        editorAccessoryhandler.switcher = accessoryViewSwitcher
        
        return accessoryViewSwitcher
    }
    
    private let menuActionsViewSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.isFourInch ? 160 : 215
    )
}
