import UIKit
import BlocksModels
import SwiftUI

final class EditorAccessoryViewModel {
    typealias MenuItemType = EditorAccessoryView.MenuItem.MenuItemType
    typealias TypeItem = ChangeTypeAccessoryItemViewModel.Item

    var block: BlockModelProtocol!
    
    weak var customTextView: CustomTextView?
    weak var delegate: EditorAccessoryViewDelegate?

    @Published private(set) var isTypesViewVisible: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()
    
    private let handler: EditorActionHandlerProtocol
    private let router: EditorRouter
    private let searchService: SearchServiceProtocol
    
    init(
        router: EditorRouter,
        handler: EditorActionHandlerProtocol,
        searchService: SearchServiceProtocol
    ) {
        self.router = router
        self.handler = handler
        self.searchService = searchService
        let supportedTypes = searchService.search(text: "")?.compactMap { object in
            
            TypeItem(
                id: object.id,
                title: object.name,
                image: object.iconEmoji.map { ObjectIconImage.icon(.emoji(.init($0))) },
                action: { print("Bambaleya")}
            )
        }

        self.supportedTypes = supportedTypes!
    }
    
    func handleMenuItemTap(_ menuItem: MenuItemType) {
        guard let textView = customTextView?.textView, let delegate = delegate else {
            return
        }

        switch menuItem {
        case .mention:
            textView.insertStringAfterCaret(
                TextTriggerSymbols.mention(prependSpace: shouldPrependSpace(textView: textView))
            )

            handler.handleActionForFirstResponder(
                .textView(
                    action: .changeText(textView.attributedText),
                    block: block
                )
            )

            delegate.showMentionsView()
        case .slash:
            textView.insertStringAfterCaret(TextTriggerSymbols.slashMenu)

            handler.handleActionForFirstResponder(
                .textView(
                    action: .changeText(textView.attributedText),
                    block: block
                )
            )

            delegate.showSlashMenuView()
        case .style:
            router.showStyleMenu(information: block.information)
        }
    }

    func handleDoneButtonTap() {
        UIApplication.shared.hideKeyboard()
    }

    func toogleChangeTypeState() {
        isTypesViewVisible.toggle()
    }
    
    private func shouldPrependSpace(textView: UITextView) -> Bool {
        let carretInTheBeginingOfDocument = textView.isCarretInTheBeginingOfDocument
        let haveSpaceBeforeCarret = textView.textBeforeCaret?.last == " "
        
        return !(carretInTheBeginingOfDocument || haveSpaceBeforeCarret)
    }
}

extension EditorAccessoryViewModel: ChangeTypeItemProvider {
    var typesPublisher: Published<[ChangeTypeAccessoryItemViewModel.Item]>.Publisher {
        $supportedTypes
    }
}
