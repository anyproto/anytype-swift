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
    @Published private(set) var isChangeTypeAvailable: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()

    private let document: BaseDocumentProtocol
    private let handler: EditorActionHandlerProtocol
    private let router: EditorRouter
    private let searchService: SearchServiceProtocol
    
    init(
        router: EditorRouter,
        handler: EditorActionHandlerProtocol,
        searchService: SearchServiceProtocol,
        document: BaseDocumentProtocol
    ) {
        self.router = router
        self.handler = handler
        self.searchService = searchService
        self.document = document

        fetchSupportedTypes()

        updateAccessoryViewState()
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

    func textDidChange() {
        updateAccessoryViewState()
    }

    private func updateAccessoryViewState() {
        let isDocumentEmpty = document.isDocumentEmpty

        isTypesViewVisible = isDocumentEmpty// if isDocumentEmpty !=  {  = false }

        isChangeTypeAvailable = isDocumentEmpty
    }
    
    private func shouldPrependSpace(textView: UITextView) -> Bool {
        let carretInTheBeginingOfDocument = textView.isCarretInTheBeginingOfDocument
        let haveSpaceBeforeCarret = textView.textBeforeCaret?.last == " "
        
        return !(carretInTheBeginingOfDocument || haveSpaceBeforeCarret)
    }

    private func fetchSupportedTypes() {
        let supportedTypes = searchService.searchObjectTypes(text: "")?.map { object -> TypeItem in
            let emoji = IconEmoji(object.iconEmoji).map { ObjectIconImage.icon(.emoji($0)) } ??  ObjectIconImage.image(UIImage())
            return TypeItem(
                id: object.id,
                title: object.name,
                image: emoji,
                action: { [weak handler] in handler?.setObjectTypeUrl(object.id) }
            )
        }

        self.supportedTypes = supportedTypes!
    }
}

private extension BaseDocumentProtocol {
    var isDocumentEmpty: Bool {
        let childrenBlocks = blocksContainer
            .children(of: objectId)
            .filter { $0 != "header" }

        if childrenBlocks.count == 0 {
            return true
        }

        // Then it would be Note
        if childrenBlocks.count == 1, let lastBlock = childrenBlocks.last {
            let lastBlockContent = blocksContainer.model(id: lastBlock)
            return lastBlockContent?.information.content.isEmpty ?? false
        }

        return false
    }
}

extension EditorAccessoryViewModel: ChangeTypeItemProvider {
    var typesPublisher: Published<[ChangeTypeAccessoryItemViewModel.Item]>.Publisher {
        $supportedTypes
    }
}
